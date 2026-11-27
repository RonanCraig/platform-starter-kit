output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "The DNS name of the Application Load Balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.this.name
  description = "The name of the Auto Scaling group"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "The ARN of the target group for the Application Load Balancer"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "The ID of the security group for the Application Load Balancer"
}

output "instance_security_group_id" {
  description = "ID of the instances' security group"
  value       = aws_security_group.app.id
}
