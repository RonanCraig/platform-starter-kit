# platform-starter-kit

Reusable Terraform modules for building production-style AWS infrastructure — networking, compute, database and CI — following the practices platform teams use: least privilege, no long-lived credentials, security scanning and remote state.

## Planned modules
- vpc: a VPC (Virtual Private Cloud) across multiple AZs (Availability Zones) with public and private subnets, an internet gateway, route tables, and optional NAT (Network Address Translation) gateways
- service: an ALB (Application Load Balancer) plus an Auto Scaling group with a launch template, health checks and scaling policies
- database: RDS (Relational Database Service) PostgreSQL in private subnets, encrypted, optionally Multi-AZ, with the password kept in Secrets Manager
- CI wiring: GitHub Actions running fmt/validate, a security scan, plan on every PR (pull request), and apply with approval, authenticated with OIDC (OpenID Connect)

## Principles
- No hard-coded account IDs or Regions. 
- No long-lived credentials. 
- State is never committed. 
- Least privilege and encryption by default.
- Every module has typed variables with descriptions, outputs, and a working example in examples/.
- Checked in CI: formatting, validation and a security scan (e.g. Checkov or Trivy) on every PR.
- Pinned versions. 
- Cost-aware. 