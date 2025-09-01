resource "azurerm_role_definition" "operator" {
  for_each  = var.team_locations

  name        = "${var.environment}-${each.key}-Operator"
  scope       = azurerm_resource_group.team_resource_group[each.key].id
  permissions {
    actions     = [
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action"
    ]
    not_actions = []
  }
  assignable_scopes = [azurerm_resource_group.team_resource_group[each.key].id]
}

resource "azurerm_role_definition" "developer" {
  for_each  = var.team_locations
  name        = "${var.environment}-${each.key}-Developer"
  scope       = azurerm_resource_group.team_resource_group[each.key].id
  permissions {
    actions     = [
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Compute/virtualMachines/redeploy/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/resources/read",
      "Microsoft.Resources/deployments/validate/action",
      "Microsoft.Network/networkSecurityGroups/write",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Resources/deployments/write",
      "Microsoft.Resources/deployments/read"

    ]
    not_actions = []
  }
  assignable_scopes = [azurerm_resource_group.team_resource_group[each.key].id]
}

resource "azurerm_role_definition" "read_only" {
  for_each  = var.team_locations

  name        = "${var.environment}-${each.key}-Readonly"
  scope       = azurerm_resource_group.team_resource_group[each.key].id
  description = "Custom role with read-only access to all resources in the resource group"

  permissions {
    actions     = [
      "*/read",                          # Read access to all resource types
      "Microsoft.Support/*"             # Allow support ticket creation
    ]
    not_actions = [
      "*"                                # Explicitly deny all write/delete actions
    ]
  }

  assignable_scopes = [azurerm_resource_group.team_resource_group[each.key].id]
}

resource "azurerm_log_analytics_workspace" "team_logs" {
  for_each  = var.team_locations
  name                = replace("logs-${var.environment}-${each.key}", "_", "-")
  location            = each.value
  resource_group_name = each.key
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Team = each.key   
    Environment = var.environment
  }
}