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

# 1. CREATE your new deployment resource group container automatically
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final1"
  location = "eastus2" # Deployed to East US 2 to bypass regional environment restrictions
}

# 2. CREATE a fresh Log Analytics Workspace to collect your application logs
resource "azurerm_log_analytics_workspace" "store_law" {
  name                = "law-store-logs-final1-prod"
  location            = azurerm_resource_group.store_rg.location
  resource_group_name = azurerm_resource_group.store_rg.name
  sku                 = "PerGB2018" # Standard pricing tier required for log retention
  retention_in_days   = 30
}

# 3. Build a fresh Container App Environment profile container linked to your logs
resource "azurerm_container_app_environment" "store_env" {
  name                       = "cae-store-env-final1-prod-v3"
  location                   = azurerm_resource_group.store_rg.location
  resource_group_name        = azurerm_resource_group.store_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.store_law.id
}

# 4. Spin up your lightweight Nginx container to host your HTML pages natively
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store"
  container_app_environment_id = azurerm_container_app_environment.store_env.id
  resource_group_name          = azurerm_resource_group.store_rg.name # Fixed reference from data to resource
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
