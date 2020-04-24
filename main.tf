resource "azurerm_resource_group" "polkadot" {
  name     = var.cluster_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "polkadot" {
  name                = var.cluster_name
  location            = "${azurerm_resource_group.polkadot.location}"
  resource_group_name = "${azurerm_resource_group.polkadot.name}"
  dns_prefix          = "polkadot"
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.machine_type
    os_disk_size_gb = 30
    type            = "AvailabilitySet"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  enable_pod_security_policy = false
}

resource "azurerm_virtual_network" "polkadot" {
  name                = "polkadot"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.polkadot.location}"
  resource_group_name = "${azurerm_resource_group.polkadot.name}"
}

resource "azurerm_subnet" "polkadot" {
  name                      = "polkadot"
  resource_group_name       = "${azurerm_resource_group.polkadot.name}"
  virtual_network_name      = "${azurerm_virtual_network.polkadot.name}"
  address_prefix            = "10.0.1.0/24"
}

resource "azurerm_public_ip" "polkadot" {
  name                = "polkadot"
  location            = "${azurerm_resource_group.polkadot.location}"
  resource_group_name = "${azurerm_resource_group.polkadot.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "polkadot" {
  name                = "polkadot"
  location            = "${azurerm_resource_group.polkadot.location}"
  resource_group_name = "${azurerm_resource_group.polkadot.name}"
}

resource "azurerm_network_security_rule" "outbound" {
  name                        = "outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.polkadot.name}"
  network_security_group_name = "${azurerm_network_security_group.polkadot.name}"
}

resource "azurerm_network_security_rule" "p2p" {
  name                        = "p2p"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "30100-30101"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.polkadot.name}"
  network_security_group_name = "${azurerm_network_security_group.polkadot.name}"
}

resource "azurerm_subnet_network_security_group_association" "polkadot" {
  subnet_id                 = "${azurerm_subnet.polkadot.id}"
  network_security_group_id = "${azurerm_network_security_group.polkadot.id}"
}
