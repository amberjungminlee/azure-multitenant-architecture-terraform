output "operator_role_definitions" {
    value = azurerm_role_definition.operator
    description = "Information of all the operator roles that were created for each team."
}

output "developer_role_definitions" {
    value = azurerm_role_definition.developer
    description = "Information of all the developer roles that were created for each team."
}

output "readonly_role_definitions" {
    value = azurerm_role_definition.read_only
    description = "Information of all the read-only roles that were created for each team."
}