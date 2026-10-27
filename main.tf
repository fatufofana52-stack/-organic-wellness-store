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

# 1. CREATE your new resource group container for final4 inside East US
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final5" # Updated to final4
  location = "eastus"
}

# 2. CREATE a fresh Log Analytics Workspace inside East US for final4 logs
resource "azurerm_log_analytics_workspace" "store_law" {
  name                = "law-store-logs-final4-prod" # Updated to final4
  location            = azurerm_resource_group.store_rg.location
  resource_group_name = azurerm_resource_group.store_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 3. HOOK INTO your existing showcasing environment safely
data "azurerm_container_app_environment" "store_env" {
  name                = "cae-bootcamp-env"
  resource_group_name = "rg-cloud-portfolio-v3"
}

# 4. Spin up your lightweight Nginx container inside the portfolio environment
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store-final4" # Updated to final4
  container_app_environment_id = data.azurerm_container_app_environment.store_env.id 
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
