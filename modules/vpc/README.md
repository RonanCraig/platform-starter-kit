# vpc

A VPC (Virtual Private Cloud) across 2–3 Availability Zones with one public and one private subnet per AZ (Availability Zone), an internet gateway, public and private route tables, a locked-down default security group, and an optional single NAT (Network Address Translation) gateway.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "starter-dev"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 2
  enable_nat_gateway = false # billed hourly; enable only when private subnets need outbound internet access
}
```

Subnet CIDRs are derived from `vpc_cidr` with `cidrsubnet()`:
- public subnets get `10.0.1.0/24`, `10.0.2.0/24`, …
- private subnets get `10.0.11.0/24`, `10.0.12.0/24`, …

AZs are looked up from the Region rather than hard-coded.

The VPC's default security group is managed with all of its rules removed, so anything launched without an explicit security group receives no traffic.

A single NAT gateway is a cost trade-off: if its AZ fails, the private subnets lose outbound access. Production would use one NAT gateway per AZ.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Prefix for resource `Name` tags |
| `vpc_cidr` | string | `10.0.0.0/16` | CIDR block for the VPC |
| `az_count` | number | `2` | Number of AZs to use (2–3) |
| `enable_nat_gateway` | bool | `false` | Create a single NAT gateway and a default route for the private subnets |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_ids` | IDs of the private subnets |
| `nat_gateway_id` | ID of the NAT gateway, or `null` when disabled |
