terraform {
  required_version = ">= 1.5.0"
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = each.value.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_inbound" {
  for_each = {
    for pair in flatten([
      for subnet_key, subnet in var.subnets : [
        for rule_key, rule in var.inbound_rules : {
          unique_key             = "${subnet_key}-${rule_key}"
          subnet_key             = subnet_key
          rule_name              = rule.name
          priority               = rule.priority
          protocol               = rule.protocol
          destination_port_range = rule.destination_port_range
        }
      ]
    ]) : pair.unique_key => pair
  }

  name                        = each.value.rule_name
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefixes     = var.allowed_inbound_source_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_key].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}