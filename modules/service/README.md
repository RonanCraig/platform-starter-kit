# service

An internet-facing ALB (Application Load Balancer) in public subnets, in front of an Auto Scaling group of EC2 (Elastic Compute Cloud) instances in private subnets.

## Usage

```hcl
module "service" {
  source = "../../modules/service"

  name               = "starter-dev"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}
```

## How it works

- **Traffic:** internet → ALB (port 80) → instances (`app_port`). The instance security group only accepts traffic from the ALB security group.
- **Instances:**
  - the latest Amazon Linux 2023 AMI (Amazon Machine Image), looked up from SSM (Systems Manager) Parameter Store
  - IMDSv2 (Instance Metadata Service version 2) required
  - a static page served by Python's built-in HTTP server, so no NAT gateway is needed
- **Self-healing:** `health_check_type = "ELB"` replaces instances that fail the ALB health check, not just instances that have stopped.
- **Scaling:** a target-tracking policy holds average CPU at 50%. `desired_capacity` is only used at creation (`ignore_changes`), so `terraform apply` never undoes a scale-out.
- **Safe replacement:** security groups use `name_prefix` with `create_before_destroy`, so a replacement is created before the old one is removed (AWS won't delete a security group that is still attached).

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Prefix for resource names and `Name` tags |
| `vpc_id` | string | required | ID of the VPC to deploy into |
| `public_subnet_ids` | list(string) | required | Subnets for the ALB (at least 2 AZs) |
| `private_subnet_ids` | list(string) | required | Subnets for the instances |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `min_size` | number | `2` | Minimum instances in the Auto Scaling group |
| `max_size` | number | `4` | Maximum instances in the Auto Scaling group |
| `desired_capacity` | number | `2` | Initial instance count; scaling policies manage it after creation |
| `app_port` | number | `80` | Port the application listens on |

## Outputs

| Name | Description |
|---|---|
| `alb_dns_name` | DNS name of the ALB |
| `asg_name` | Name of the Auto Scaling group |
| `target_group_arn` | ARN of the target group |
| `alb_security_group_id` | ID of the ALB security group |
| `instance_security_group_id` | ID of the instance security group; pass it to `database` as `allowed_security_group_id` |
