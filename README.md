# platform-starter-kit

Reusable Terraform modules for building production-style AWS infrastructure — networking, compute, database and CI — following the practices platform teams use: least privilege, no long-lived credentials, security scanning and remote state.

## Modules

| Module | Status | What it builds |
|---|---|---|
| [`vpc`](modules/vpc) | ✅ Available | A VPC (Virtual Private Cloud) across 2–3 AZs (Availability Zones) with public and private subnets, an internet gateway, route tables, and an optional NAT (Network Address Translation) gateway |
| `service` | Planned | An ALB (Application Load Balancer) plus an Auto Scaling group with a launch template, health checks and scaling policies |
| `database` | Planned | RDS (Relational Database Service) PostgreSQL in private subnets, encrypted, optionally Multi-AZ, with the password kept in Secrets Manager |
| CI wiring | Planned | GitHub Actions running fmt/validate, a security scan, plan on every PR (pull request), and apply with approval, authenticated with OIDC (OpenID Connect) |

## Repository layout

```
modules/
  vpc/              # reusable module: no provider config, minimum provider version only
examples/
  basic/            # root module showing minimal usage; provider config and pinned versions live here
```

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "starter-dev"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 2
  enable_nat_gateway = false # NAT gateways are billed hourly; enable only when private subnets need outbound internet access
}
```

Subnet CIDRs are derived from `vpc_cidr` with `cidrsubnet()`: public subnets get `10.0.1.0/24`, `10.0.2.0/24`, …; private subnets get `10.0.11.0/24`, `10.0.12.0/24`, …. AZs are looked up from the Region rather than hard-coded.

To try the example:

```bash
cd examples/basic
terraform init
terraform plan                                  # NAT gateway off
terraform plan -var enable_nat_gateway=true     # NAT gateway on
```

### `vpc` inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — (required) | Prefix for resource `Name` tags |
| `vpc_cidr` | string | `10.0.0.0/16` | CIDR block for the VPC |
| `az_count` | number | `2` | Number of AZs to use (2–3) |
| `enable_nat_gateway` | bool | `false` | Create a single NAT gateway and a default route for the private subnets |

### `vpc` outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_ids` | IDs of the private subnets |
| `nat_gateway_id` | ID of the NAT gateway, or `null` when disabled |

## Principles

- No hard-coded account IDs or Regions.
- No long-lived credentials.
- State is never committed.
- Least privilege and encryption by default.
- Every module has typed variables with descriptions, outputs, and a working example in `examples/`.
- Checked in CI: formatting, validation and a security scan (e.g. Checkov or Trivy) on every PR.
- Pinned versions.
- Cost-aware.

## Requirements

- Terraform >= 1.10
- AWS provider `~> 6.0` (pinned in each example)
- An AWS account, with credentials supplied by the standard AWS credential provider chain (e.g. `aws login`) — no access keys in code
- Applying the examples creates billable resources (notably the optional NAT gateway); run `terraform destroy` when finished
