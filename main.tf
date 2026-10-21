terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# 1. Create a clean Resource Group container safely inside East US (v3 slot)
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-v3"
  location = "eastus"
}

# 2. Provision an approved Log Analytics Workspace for monitoring metrics
resource "azurerm_log_analytics_workspace" "store_law" {
  name                = "law-store-logs"
  location            = azurerm_resource_group.store_rg.location
  resource_group_name = azurerm_resource_group.store_rg.name
  sku                 = "PerGB2018"
}

# 3. Create the Container App Environment platform link
resource "azurerm_container_app_environment" "store_env" {
  name                       = "cae-store-env"
  location                   = azurerm_resource_group.store_rg.location
  resource_group_name        = azurerm_resource_group.store_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.store_law.id
}

# 4. Spin up a lightweight Nginx web server node container to host our HTML natively
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store"
  container_app_environment_id = azurerm_container_app_environment.store_env.id
  resource_group_name          = azurerm_resource_group.store_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "web-storefront"
      image  = "nginx:alpine" # Lightest, most secure open-source static asset server engine
      cpu    = "0.25"
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    target_port                = 80
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
