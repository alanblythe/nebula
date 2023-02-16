
# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group, rg-nebula-dev
resource "azurerm_resource_group" "rg" {
  name     = "rg-nebula${random_integer.ri.result}-dev"
  location = var.location
}

data "azurerm_container_registry" "reg" {
  name                = "crnebula"
  resource_group_name = "rg-nebula-dev"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "app-nebula${random_integer.ri.result}-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "api" {
  name                = "webapp-nebula${random_integer.ri.result}-api-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = "${azurerm_service_plan.appserviceplan.id}"

  site_config {
    always_on        = true
    application_stack {
      docker_image     = "${data.azurerm_container_registry.reg.login_server}/nebula-api"
      docker_image_tag = "latest"
    }
    # linux_fx_version = "DOCKER|${data.azurerm_container_registry.reg.login_server}/nebula-api:latest"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${data.azurerm_container_registry.reg.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "${data.azurerm_container_registry.reg.admin_username}"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "${data.azurerm_container_registry.reg.admin_password}"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_static_site" "web" {
  name                = "stapp-nebula${random_integer.ri.result}-web-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

