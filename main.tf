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

# 1. CREATE or reference your resource group container in the permitted region
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final1"
  location = "eastus" # Switched back to East US to satisfy your subscription policy
}

# 2. CREATE a fresh Log Analytics Workspace inside East US
resource "azurerm_log_analytics_workspace" "store_law" {
  name                = "law-store-logs-final1-prod"
  location            = azurerm_resource_group.store_rg.location
  resource_group_name = azurerm_resource_group.store_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 3. READ from the existing Container App Environment in East US instead of building a new one
data "azurerm_container_app_environment" "store_env" {
  name                = "cae-store-env-final1-prod-v3" # Change this name to match your existing environment name if it differs
  resource_group_name = azurerm_resource_group.store_rg.name
}

# 4. Spin up your lightweight Nginx container inside the permitted environment layout
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store"
  container_app_environment_id = data.azurerm_container_app_environment.store_env.id # Uses the read data block
  resource_group_name          = azurerm_resource_group.store_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "web-storefront"
      image  = "nginx:alpine"
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
