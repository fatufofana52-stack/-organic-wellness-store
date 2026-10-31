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

# 1. CREATE your resource group container for final11 inside East US
resource "azurerm_resource_group" "store_rg" {
  name     = "rg-organic-wellness-store-final11"
  location = "eastus"
}

# 2. CREATE an Azure Storage Account inside East US
resource "azurerm_storage_account" "store_account" {
  name                     = "biovitasstorefinal11"
  resource_group_name      = azurerm_resource_group.store_rg.name
  location                 = azurerm_resource_group.store_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
  }
}

# 3. Generate a secure temporary connection string for the file upload
data "azurerm_storage_account_sas" "upload_sas" {
  connection_string = azurerm_storage_account.store_account.primary_connection_string
  https_only        = true
  signed_version    = "2021-08-06"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2026-01-01T00:00:00Z"
  expiry = "2027-01-01T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Output your live website link
output "website_url" {
  value = azurerm_storage_account.store_account.primary_web_endpoint
}

# Output the secure token for the GitHub runner
output "sas_token" {
  value     = data.azurerm_storage_account_sas.upload_sas.sas
  sensitive = true
}
