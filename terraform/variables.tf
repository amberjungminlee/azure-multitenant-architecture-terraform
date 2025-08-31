# baseline which assumes 
variable "environment" {
    description = "The deployment environment: dev | sit | uat | prod"
    type = string
    default = "sit"
}

# Each individual team will have their own set of resources stored in map(string) values
variable "team_locations" {
    description = "The list of teams / projects and their locations that will require a resource group in this account"
    type = map(string)
    default = {
        mars_climate_research_team = "westus2"
        earth_observation_data_team = "eastus"
    }
}

variable "team_networks" {
  description = "Per-team network configurations"
  type = map(object({
    sit = map(list(string))
    uat = map(list(string))
    prod = map(list(string))
  }))
  default = {
    mars_climate_research_team = {
      sit = {
        address_space   = ["11.0.0.0/16"]
        subnet_prefixes = ["11.0.2.0/24"]
      }
      uat = {
        address_space   = ["12.0.0.0/16"]
        subnet_prefixes = ["12.0.2.0/24"]
      }
      prod = {
        address_space   = ["14.0.0.0/16"]
        subnet_prefixes = ["14.0.2.0/24"]
      }
    }
    earth_observation_data_team = {
      sit = {
        address_space   = ["15.1.0.0/16"]
        subnet_prefixes = ["15.1.2.0/24"]
      }
      uat = {
        address_space   = ["16.1.0.0/16"]
        subnet_prefixes = ["16.1.2.0/24"]
      }
      prod = {
        address_space   = ["17.1.0.0/16"]
        subnet_prefixes = ["17.1.2.0/24"]
      }
    }
  }
}

variable "shared_location" {
  description = "Location of where shared resources will be stored"
  type = string
  default = "East US"  
}
