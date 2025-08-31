resource "azuread_user" "example" {
  user_principal_name = "ariel@marsresearch.edu"
  display_name        = "Ariel"
  mail_nickname       = "Ariel"
  password            = "rSecretP@sswd99!"
  company_name        = "Mars Research"
}

resource "azuread_user" "example" {
  user_principal_name = "bob@earthdataresearch.edu"
  display_name        = "Bob"
  mail_nickname       = "Bob"
  password            = "rSecretP@sswd99!"
  company_name        = "Earthdata Research"
}

