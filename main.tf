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

# 1. CREATE your resource group container for final8 inside East US
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final8"
  location = "eastus"
}

# 2. CREATE a native Azure Static Web App to host your HTML/CSS files natively on the free tier
resource "azurerm_static_web_app" "store_site" {
  name                = "biovita-organic-store-final8"
  resource_group_name = azurerm_resource_group.store_rg.name
  location            = "eastus2" # SWAs use eastus2 or westus2 for global edge delivery
  sku_tier            = "Free"    # Locks it strictly into the zero-cost tier
  sku_size            = "Free"
}
