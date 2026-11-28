# database

RDS (Relational Database Service) PostgreSQL in private subnets, reachable on port 5432 from a single allowed security group.

## Usage

```hcl
module "database" {
  source = "../../modules/database"

  name                      = "starter-dev"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  allowed_security_group_id = module.service.instance_security_group_id
}
```

## How it works

- **The password never enters Terraform.** With `manage_master_user_password = true`, RDS generates the master password, stores it in Secrets Manager and rotates it. Terraform only sees the secret's ARN (`master_user_secret_arn`). A `password` variable or a `random_password` resource would store the plaintext in state.
- **Network:**
  - `publicly_accessible = false`
  - private subnets only
  - the security group admits 5432 from `allowed_security_group_id` and nothing else
- **Data protection:**
  - storage encrypted at rest
  - 7-day automated backups
  - snapshots inherit tags
- **Access and observability:**
  - IAM database authentication is enabled, so apps can use short-lived tokens instead of the password
  - Performance Insights is enabled (7-day free retention)
  - the `postgresql`, `upgrade` and `iam-db-auth-error` logs are exported to CloudWatch
- **Safe by default:** `deletion_protection = true` and `skip_final_snapshot = false` unless the caller opts out. `examples/web-service` opts out, because it's destroyed after every test.
- **Engine version:** set the major version only (`"18"`); minor versions upgrade automatically in the maintenance window.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Prefix for the DB identifier, subnet group and security group names |
| `vpc_id` | string | required | VPC for the security group |
| `private_subnet_ids` | list(string) | required | Subnets for the DB subnet group (at least 2 AZs) |
| `allowed_security_group_id` | string | required | The only security group allowed to connect on 5432 |
| `instance_class` | string | `db.t4g.micro` | Instance class |
| `allocated_storage` | number | `20` | Storage in GB (gp3) |
| `engine_version` | string | `"18"` | PostgreSQL major version |
| `db_name` | string | `"app"` | Database created inside the instance |
| `multi_az` | bool | `false` | Synchronous standby in a second AZ (doubles the cost) |
| `deletion_protection` | bool | `true` | Block deletion of the instance |
| `skip_final_snapshot` | bool | `false` | Skip the final snapshot on deletion |

## Outputs

| Name | Description |
|---|---|
| `address` | DB hostname |
| `port` | DB port |
| `security_group_id` | ID of the DB security group |
| `master_user_secret_arn` | ARN of the Secrets Manager secret holding the master password |
