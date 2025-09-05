terraform {
  backend "http" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "864fc5e1-6791-459d-817a-201b89d27a4c" # lentidas' Microsoft Azure for Students subscription
}
