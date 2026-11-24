output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC created by this module"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "The IDs of the public subnets created by this module"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "The IDs of the private subnets created by this module"
}

output "nat_gateway_id" {
  value       = one(aws_nat_gateway.this[*].id)
  description = "The ID of the NAT gateway, if enabled"
}