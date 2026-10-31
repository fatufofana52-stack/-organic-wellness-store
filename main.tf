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

# 1. CREATE your fresh resource group container for final9 inside East US
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final9"
  location = "eastus"
}

# 2. CREATE a native Azure Static Web App forced tightly into East US to satisfy your account policy
resource "azurerm_static_web_app" "store_site" {
  name                = "biovita-organic-store-final9"
  resource_group_name = azurerm_resource_group.store_rg.name
  location            = "eastus" # Forced to eastus to clear your account firewall policy
  sku_tier            = "Free"   # Free tier compliant
  sku_size            = "Free"
}
