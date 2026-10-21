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

# 1. READ from your existing active final1 resource group container
data "azurerm_resource_group" "store_rg" {
  name = "rg-organic-wellness-store-final1"
}

# 2. READ from your existing Log Analytics Workspace instead of rebuilding it
data "azurerm_log_analytics_workspace" "store_law" {
  name                = "law-store-logs-final1-prod"
  resource_group_name = data.azurerm_resource_group.store_rg.name
}

# 3. Build a fresh Container App Environment profile container
resource "azurerm_container_app_environment" "store_env" {
  name                       = "cae-store-env-final1-prod-v3" # Bumped suffix to ensure a clean path
  location                   = data.azurerm_resource_group.store_rg.location
  resource_group_name        = data.azurerm_resource_group.store_rg.name
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.store_law.id
}

# 4. Spin up your lightweight Nginx container to host your HTML pages natively
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store"
  container_app_environment_id = azurerm_container_app_environment.store_env.id
  resource_group_name          = data.azurerm_resource_group.store_rg.name
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
