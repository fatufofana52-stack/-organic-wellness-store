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

# 1. Target your original project group where the free slot resides
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-cloud-bootcamp-project"
  location = "eastus"
}

# 2. Deploy your supplement store directly onto your existing free environment!
resource "azurerm_container_app" "store_app" {
  name                         = "biovita-organic-store"
  container_app_environment_id = "/subscriptions/a3904a1d-fde9-4185-bc58-808196406b61/resourceGroups/rg-cloud-bootcamp-project/providers/Microsoft.App/managedEnvironments/cae-bootcamp-env"
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
