resource "azurerm_resource_group" "shared_resource_group" {
  name     = "shared-resource-group"
  location = var.shared_location
  tags = {
    Team = "AllUsers"
  }
}

resource "azuread_group" "all_users" {
  display_name     = "AllUsers"
  security_enabled = true
}

data "azuread_users" "all" {
  return_all = true
}

resource "azuread_group_member" "members" {
  for_each       = { for user in data.azuread_users.all.users : user.object_id => user }
  
  group_object_id = replace(azuread_group.all_users.id, "//groups//", "")
  member_object_id = each.key

}

# Shared resources
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "shared_key_vault" {
  name                        = "AmbersTestSharedVault123"
  location                    = azurerm_resource_group.shared_resource_group.location
  resource_group_name         = azurerm_resource_group.shared_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  
  tags = {
    Team = "AllUsers"
  }
}


resource "azurerm_log_analytics_workspace" "shared_logs" {
  name                = "shared-logs"
  location            = azurerm_resource_group.shared_resource_group.location
  resource_group_name = azurerm_resource_group.shared_resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    Team = "AllUsers"
  }
}