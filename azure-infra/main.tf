terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatepj9l3"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source              = "./modules/resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "aks_cluster" {
  source = "./modules/aks"
  #   name                = var.k8s_name
  resource_group_name = var.resource_group_name
}

module "pub_ip" {
  source              = "./modules/public_ip"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "load_balancer_demo" {
  source              = "./modules/load-balancer"
  public_ip_id        = module.pub_ip.public_ip_id
  resource_group_name = var.resource_group_name
  location            = var.location
}