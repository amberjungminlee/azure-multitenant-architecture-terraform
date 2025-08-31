resource "azurerm_role_assignment" "dev_user_contributor" {
  principal_id         = azuread_user.ariel.object_id
  role_definition_name = "sit-mars_climate_research_team-Developer"
  scope                = "/subscriptions/your-sub-id/resourceGroups/dev-rg"
}