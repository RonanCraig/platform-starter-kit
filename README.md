# platform-starter-kit

Reusable Terraform modules for building production-style AWS infrastructure — networking, compute, database and CI — following the practices platform teams use: least privilege, no long-lived credentials, security scanning and remote state.

## Modules

| Module | Status | What it builds |
|---|---|---|
| [`vpc`](modules/vpc) | ✅ Available | A VPC (Virtual Private Cloud) across 2–3 AZs (Availability Zones) with public and private subnets, an internet gateway, route tables, and an optional NAT (Network Address Translation) gateway |
| [`service`](modules/service) | ✅ Available | An internet-facing ALB (Application Load Balancer) in public subnets, plus an Auto Scaling group of EC2 (Elastic Compute Cloud) instances in private subnets with a launch template, ELB (Elastic Load Balancing) health checks and CPU (Central Processing Unit) target-tracking scaling |
| `database` | Planned | RDS (Relational Database Service) PostgreSQL in private subnets, encrypted, optionally Multi-AZ, with the password kept in Secrets Manager |
| CI wiring | Planned | GitHub Actions running fmt/validate, a security scan, plan on every PR (pull request), and apply with approval, authenticated with OIDC (OpenID Connect) |

## Repository layout

```
modules/
  vpc/              # reusable module: no provider config, minimum provider version only
  service/          # ALB + Auto Scaling group, takes VPC outputs as inputs
examples/
  basic/            # root module showing minimal usage; provider config and pinned versions live here
  web-service/      # root module wiring vpc -> service into a working load-balanced web tier
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

### `service` usage

```hcl
module "service" {
  source = "../../modules/service"

  name               = "starter-dev"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}
```

Traffic flows internet → ALB (public subnets, port 80) → instances (private subnets, `app_port`). The instance security group only accepts traffic from the ALB security group, so instances have no public exposure. Instances use the latest Amazon Linux 2023 AMI (Amazon Machine Image), looked up from SSM (Systems Manager) Parameter Store, require IMDSv2 (Instance Metadata Service version 2), and serve a static page with Python's built-in HTTP (Hypertext Transfer Protocol) server, so no NAT gateway is needed.

The Auto Scaling group uses `health_check_type = "ELB"`, so instances failing the ALB health check are replaced, and a target-tracking policy holds average CPU at 50%. `desired_capacity` is only used at creation (`ignore_changes`), so `terraform apply` never undoes a scale-out.

To try it:

```bash
cd examples/web-service
terraform init
terraform apply
curl "http://$(terraform output -raw alb_dns_name)"   # may take a few minutes while instances pass health checks
terraform destroy
```

### `service` inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — (required) | Prefix for resource names and `Name` tags |
| `vpc_id` | string | — (required) | ID of the VPC to deploy into |
| `public_subnet_ids` | list(string) | — (required) | Subnets for the ALB |
| `private_subnet_ids` | list(string) | — (required) | Subnets for the instances |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `min_size` | number | `2` | Minimum instances in the Auto Scaling group |
| `max_size` | number | `4` | Maximum instances in the Auto Scaling group |
| `desired_capacity` | number | `2` | Initial instance count; scaling policies manage it after creation |
| `app_port` | number | `80` | Port the application listens on |

### `service` outputs

| Name | Description |
|---|---|
| `alb_dns_name` | DNS (Domain Name System) name of the ALB |
| `asg_name` | Name of the Auto Scaling group |
| `target_group_arn` | ARN (Amazon Resource Name) of the target group |
| `alb_security_group_id` | ID of the ALB security group |
| `instance_security_group_id` | ID of the instance security group |

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
- Applying the examples creates billable resources (notably the optional NAT gateway and the ALB, both billed hourly); run `terraform destroy` when finished
