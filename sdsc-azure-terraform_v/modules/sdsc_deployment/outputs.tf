output "deployment_name" {
  value = azapi_resource.sdsc_arm_deployment.name
}

output "deployment_id" {
  value = azapi_resource.sdsc_arm_deployment.id
}

output "deployment_output" {
  value     = azapi_resource.sdsc_arm_deployment.output
  sensitive = true
}