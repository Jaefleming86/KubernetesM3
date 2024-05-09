# Define the Azure provider
provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "m3clusterrg" {
  name     = "m3clusterrg"
  location = "West US"
}

resource "azurerm_virtual_network" "m3clustervn" {
  name                = "m3clustervn"
  resource_group_name = azurerm_resource_group.m3clusterrg.name
  location            = azurerm_resource_group.m3clusterrg.location
  address_space       = ["10.86.0.0/16"]
}

resource "azurerm_subnet" "public1" {
  name                 = "public1"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.1.0/24"]
}

resource "azurerm_subnet" "public2" {
  name                 = "public2"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.2.0/24"]
}

resource "azurerm_subnet" "public3" {
  name                 = "public3"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.3.0/24"]
}

resource "azurerm_subnet" "private1" {
  name                 = "private1"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.11.0/24"]
}

resource "azurerm_subnet" "private2" {
  name                 = "private2"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.12.0/24"]
}

resource "azurerm_subnet" "private3" {
  name                 = "private3"
  resource_group_name  = azurerm_resource_group.m3clusterrg.name
  virtual_network_name = azurerm_virtual_network.m3clustervn.name
  address_prefixes     = ["10.86.13.0/24"]
}

resource "azurerm_kubernetes_cluster" "m3clusterrg" {
  name                = "m3clusterrg"
  location            = azurerm_resource_group.m3clusterrg.location
  resource_group_name = azurerm_resource_group.m3clusterrg.name
  dns_prefix          = "m3cluster"
  kubernetes_version  = "1.19.7"

    service_principal {
    client_id     = "{client_id}"
    client_secret = "{client_secret}"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.public1.id
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    max_pods = 110
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3

    tags = {
      "k8s-nodepool" = "true"
    }
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.m3clusterrg.kube_config.0.client_certificate
  sensitive = true
}