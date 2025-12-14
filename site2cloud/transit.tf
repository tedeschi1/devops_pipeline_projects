# Create an Azure VNet
resource "aviatrix_vpc" "vnet_transit1" {
  cloud_type           = 8
  account_name         = var.AZUREACCESSACCOUNT
  region               = var.AZUREREGION
  name                 = "vnet-transit1-${random_id.id.hex}"
  cidr                 = var.transit_gw1_address_space
  aviatrix_firenet_vpc = false
}

# Create an Aviatrix Azure Transit Network Gateway
resource "aviatrix_transit_gateway" "transit_gw1" {
  cloud_type        = 8
  account_name      = var.AZUREACCESSACCOUNT
  gw_name           = "avx-transit-gw-${random_id.id.hex}"
  vpc_id            = aviatrix_vpc.vnet_transit1.vpc_id
  vpc_reg           = var.AZUREREGION
  gw_size           = "Standard_B2ms"
  subnet            = aviatrix_vpc.vnet_transit1.subnets[0].cidr
  #zone              = "az-1"
  #ha_subnet         = "10.30.0.0/24"
  #ha_zone           = "az-2"
  #ha_gw_size        = "Standard_B1ms"
  connected_transit = true
  local_as_number = 65200
}

output "transit_vnet_id" {
  value = aviatrix_vpc.vnet_transit1.vpc_id
}

output "azure_transit_public_ip" {
  value = aviatrix_transit_gateway.transit_gw1.public_ip
}

output "azure_transit_gw_name" {
  value = aviatrix_transit_gateway.transit_gw1.gw_name
}