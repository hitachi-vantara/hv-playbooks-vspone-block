resource "azurerm_resource_group" "sdsc" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "sdsc_deployment" {
  source = "./modules/sdsc_deployment"

  resource_group_id   = azurerm_resource_group.sdsc.id
  resource_group_name = azurerm_resource_group.sdsc.name
  location            = azurerm_resource_group.sdsc.location
  template_file       = "${path.module}/templates/azure.json"
  parameters_json     = local.parameters_json

  depends_on = [
    azurerm_resource_group.sdsc
  ]
}