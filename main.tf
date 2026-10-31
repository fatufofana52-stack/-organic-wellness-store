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

# 1. CREATE your fresh resource group container for final10 inside East US
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final10"
  location = "eastus"
}

# 2. CREATE an Azure Storage Account inside East US to bypass the static web app paradox
resource "azurerm_storage_account" "store_account" {
  name                     = "biovitasstorefinal10" # Must be globally unique, lowercase letters and numbers only
  resource_group_name      = azurerm_resource_group.store_rg.name
  location                 = azurerm_resource_group.store_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enables the native static web hosting feature
  static_website {
    index_document = "index.html"
  }
}

# Output the live website link so you can click it when it's done
output "website_url" {
  value = azurerm_storage_account.store_account.primary_web_endpoint
}
