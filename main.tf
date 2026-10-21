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

# 1. Create a clean Resource Group container for our store
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store"
  location = "East US"
}

# 2. Provision the Azure Static Web App framework (100% Free Hosting SKU)
resource "azurerm_static_web_app" "store_site" {
  name                = "biovita-organic-store"
  resource_group_name = azurerm_resource_group.store_rg.name
  location            = "East US"
  sku_tier            = "Free"
  sku_size            = "Free"
}

# Output the deployment token value seamlessly for our automation engine
output "static_web_app_api_token" {
  value     = azurerm_static_web_app.store_site.api_key
  sensitive = true
}
