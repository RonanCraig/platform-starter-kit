output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.service.alb_dns_name
}
