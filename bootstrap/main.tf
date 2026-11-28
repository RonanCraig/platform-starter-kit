data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "tfstate" {
  # checkov:skip=CKV_AWS_18:Access logs need a separate log bucket; CloudTrail already records API access to state
  # checkov:skip=CKV_AWS_144:Cross-region replication is overkill for a single-person state bucket; versioning covers recovery
  # checkov:skip=CKV_AWS_145:SSE-S3 is adequate here; a customer-managed KMS key ($1/month) is only needed for key-policy control
  # checkov:skip=CKV2_AWS_62:Nothing consumes S3 event notifications from the state bucket
  bucket = "psk-tfstate-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning keeps every old copy of state forever; expire superseded versions after 90 days.
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
