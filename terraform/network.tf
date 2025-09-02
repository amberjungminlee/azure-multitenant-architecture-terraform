# Resource Group : Set of Azure resources dedicated to each team
resource "azurerm_resource_group" "team_resource_group" {
  for_each  = var.team_locations
  name      = "rg-${each.key}-${var.environment}"
  location  = each.value
  
  tags = {
    Team    = each.key
    Environment = var.environment
  }
}

# Network Security Group : Virtual firewall dedicated to each team
resource "azurerm_network_security_group" "team_network_security_group" {
  for_each            = var.team_locations

  name                = "nsg-${each.key}-${var.environment}"
  location            = azurerm_resource_group.team_resource_group[each.key].location
  resource_group_name = azurerm_resource_group.team_resource_group[each.key].name

  tags = {
    Team        = each.key
    Environment = var.environment
  }
}

# Virtual Network : Network boundary and IP space for Azure resources
resource "azurerm_virtual_network" "team_virtual_networks" {
  for_each = var.team_networks

  name                = "vnet-${each.key}-${var.environment}"
  location            = var.team_locations[each.key]
  resource_group_name = "rg-${each.key}-${var.environment}"
  address_space       = var.team_networks[each.key][var.environment].address_space

  encryption {
    enforcement = "DropUnencrypted"
  }

  dynamic "subnet" {
    for_each = each.value[var.environment].subnet_prefixes
    content {
      name = "subnet-${each.key}-${var.environment}-${replace(subnet.value, "/", "-")}"
      address_prefix = subnet.value
      security_group   = azurerm_network_security_group.team_network_security_group[each.key].id
    }
  }
  depends_on = [
    azurerm_network_security_group.team_network_security_group
  ]
  tags = {
    Team        = var.team_locations[each.key]
    Environment = var.environment
  }
}

# Network Security Rule : Allow team resources to access all outbound traffic
resource "azurerm_network_security_rule" "team_allow_outbound" {
  for_each = var.team_locations

  name                        = "allow-all-outbound-${each.key}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefix   = "*"
  resource_group_name          = "rg-${each.key}-${var.environment}"
  network_security_group_name  = "nsg-${each.key}-${var.environment}"

  depends_on = [
    azurerm_network_security_group.team_network_security_group
  ]
}

# Public IP : Public IP address for NAT gateway for each tenant
resource "azurerm_public_ip" "team_nat_ip" {
  for_each = var.team_locations

  name                = "${each.key}-nat-ip"
  location            = each.value
  resource_group_name = "rg-${each.key}-${var.environment}"
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    azurerm_network_security_group.team_network_security_group
  ]

  tags = {
    Team    = each.key
    Environment = var.environment
  }
}

# Azurerm NAT Gateway : Associates private IP with a public IP for outgoing connections
resource "azurerm_nat_gateway" "team_nat_gateway" {
  for_each = var.team_locations

  name                = "${each.key}_${var.environment}_nat"
  location            = each.value
  resource_group_name = "rg-${each.key}-${var.environment}"
  sku_name            = "Standard"
  
  idle_timeout_in_minutes = 10

  depends_on = [
    azurerm_network_security_group.team_network_security_group
  ]

  tags = {
    Team    = each.key
    Environment = var.environment
  }
}

# Azure subnets : subnet each team gets
locals {
  all_subnets = flatten([
    for team, config in var.team_networks : [
      for prefix in config[var.environment].subnet_prefixes : {
        key       = "${team}-${var.environment}-${replace(prefix, "/", "-")}"
        team      = team
        prefix    = prefix
      }
    ]
  ])
}
resource "azurerm_subnet" "team_subnets" {
  for_each = { for subnet in local.all_subnets : subnet.key => subnet }

  
  name                 = "subnet-${replace(each.value.prefix, "/", "-")}"
  resource_group_name  = azurerm_resource_group.team_resource_group[each.value.team].name
  virtual_network_name = azurerm_virtual_network.team_virtual_networks[each.value.team].name
  address_prefixes     = [each.value.prefix]
}

# Associated NATS gateway
resource "azurerm_subnet_nat_gateway_association" "team_subnet_nat_assoc" {
  for_each = azurerm_subnet.team_subnets

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.team_nat_gateway[split("-", each.key)[0]].id
}

# Associate NATS gateway with public IP address
resource "azurerm_nat_gateway_public_ip_association" "team_nat_gateway_public_ip_association" {
  for_each = var.team_locations

  nat_gateway_id = azurerm_nat_gateway.team_nat_gateway[each.key].id
  public_ip_address_id = azurerm_public_ip.team_nat_ip[each.key].id
}

# Route Table to associate with the subnet
resource "azurerm_route_table" "team_route_table" {
  for_each = var.team_locations
  name                = "${var.environment}-${each.key}-route-table"
  location            = azurerm_resource_group.team_resource_group[each.key].location
  resource_group_name = azurerm_resource_group.team_resource_group[each.key].name

  tags = {
    Team = each.key   
    Environment = var.environment
  }
}

resource "azurerm_subnet_route_table_association" "team_route_table_association" {
  for_each = var.team_locations

  subnet_id      = azurerm_subnet.team_subnets[each.key].id
  route_table_id = azurerm_route_table.team_route_table[each.key].id
}