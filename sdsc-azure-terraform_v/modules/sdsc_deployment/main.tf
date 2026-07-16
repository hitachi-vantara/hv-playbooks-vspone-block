locals {
  template_object   = jsondecode(file(var.template_file))
  parameters_object = jsondecode(var.parameters_json).parameters
}

resource "azapi_resource" "sdsc_arm_deployment" {
  type      = "Microsoft.Resources/deployments@2022-09-01"
  name      = "sdsc-arm-deployment"
  parent_id = var.resource_group_id

  body = {
    properties = {
      mode       = "Incremental"
      template   = local.template_object
      parameters = local.parameters_object
    }
  }

  response_export_values = ["*"]
}