# Create an Azure VNet
resource "aviatrix_vpc" "vnet_transit_onprem" {
  cloud_type           = 8
  account_name         = var.AZUREACCESSACCOUNT
  region               = var.AZUREREGION
  name                 = "vnet-onprem-transit-${random_id.id.hex}"
  cidr                 = var.vnet_onprem_transit_address_space
  aviatrix_firenet_vpc = false
}

# Create an Aviatrix Azure Transit Network Gateway
resource "aviatrix_transit_gateway" "onprem_transit" {
  cloud_type        = 8
  account_name      = var.AZUREACCESSACCOUNT
  gw_name           = "transit-onprem-gw1-${random_id.id.hex}"
  vpc_id            = aviatrix_vpc.vnet_transit_onprem.vpc_id
  vpc_reg           = var.AZUREREGION
  gw_size           = "Standard_B2ms"
  subnet            = aviatrix_vpc.vnet_transit_onprem.subnets[0].cidr
  #zone              = "az-1"
  #ha_subnet         = "10.30.0.0/24"
  #ha_zone           = "az-2"
  #ha_gw_size        = "Standard_B1ms"
  connected_transit = false
  local_as_number = 65201
  enable_advertise_transit_cidr = true
}

output "onprem_transit_public_ip" {
  value = aviatrix_transit_gateway.onprem_transit.public_ip
}

output "onprem_transitgw_name" {
  value = aviatrix_transit_gateway.onprem_transit.gw_name
}