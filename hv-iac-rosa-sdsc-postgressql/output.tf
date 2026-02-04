output "sds_endpoint" {
  description = "SDS Block API endpoint (Load Balancer HTTPS URL)"
  value       = "https://${data.aws_lb.lb.dns_name}"
}
output "sds_username" {
  description = "SDS admin username"
  value       = var.sds_admin_username
}

output "sds_password" {
  description = "SDS admin password after reset"
  value       = var.sds_new_password
  sensitive   = true
}

