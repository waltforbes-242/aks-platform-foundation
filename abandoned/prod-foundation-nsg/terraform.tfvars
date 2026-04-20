resource_group_name = "apf-rg-prod"
location            = "East US"

vnet_name          = "apf-vnet-prod"
vnet_address_space = ["10.77.0.0/16"]

subnets = {
  systempool1 = {
    name             = "apf-subnet-systempool1-prod"
    address_prefixes = ["10.77.0.0/22"]
    nsg_name         = "apf-nsg-systempool1-prod"
  }

  userpool1 = {
    name             = "apf-subnet-userpool1-prod"
    address_prefixes = ["10.77.4.0/22"]
    nsg_name         = "apf-nsg-userpool1-prod"
  }

  future1 = {
    name             = "apf-subnet-future1-prod"
    address_prefixes = ["10.77.8.0/22"]
    nsg_name         = "apf-nsg-future1-prod"
  }

  future2 = {
    name             = "apf-subnet-future2-prod"
    address_prefixes = ["10.77.12.0/22"]
    nsg_name         = "apf-nsg-future2-prod"
  }

  future3 = {
    name             = "apf-subnet-future3-prod"
    address_prefixes = ["10.77.16.0/22"]
    nsg_name         = "apf-nsg-future3-prod"
  }
}

inbound_rules = {
  http = {
    name                   = "allow-http-inbound"
    priority               = 100
    protocol               = "Tcp"
    destination_port_range = "80"
  }

  https = {
    name                   = "allow-https-inbound"
    priority               = 110
    protocol               = "Tcp"
    destination_port_range = "443"
  }

  ssh = {
    name                   = "allow-ssh-inbound"
    priority               = 120
    protocol               = "Tcp"
    destination_port_range = "22"
  }
}

allowed_inbound_source_prefixes = ["*"]

# To restrict inbound traffic to the sample network only, change to:
# allowed_inbound_source_prefixes = ["168.43.124.64/26"]

# To restrict inbound traffic to one specific host only, change to:
# allowed_inbound_source_prefixes = ["168.43.124.69/32"]

tags = {
  project     = "aks-platform-foundation"
  environment = "prod"
  owner       = "platform-team"
}