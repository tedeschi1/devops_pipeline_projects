resource "aviatrix_vpc" "vnet_spoke1" {
  cloud_type           = 8
  account_name         = var.AZUREACCESSACCOUNT
  region               = var.AZUREREGION
  name                 = "vnet-spoke1-${random_id.id.hex}"
  cidr                 = var.spokegw1_address_space
  aviatrix_firenet_vpc = false
}

resource "random_id" "id" {
  byte_length = 2
}

# Create an Aviatrix Azure Spoke Gateway
resource "aviatrix_spoke_gateway" "spoke_gw1" {
  cloud_type        = 8
  account_name      = var.AZUREACCESSACCOUNT
  gw_name           = "spoke-gw1-${random_id.id.hex}"
  vpc_id            = aviatrix_vpc.vnet_spoke1.vpc_id
  vpc_reg           = var.AZUREREGION
  gw_size           = "Standard_B2ms"
  subnet            = aviatrix_vpc.vnet_spoke1.subnets[0].cidr
  #zone              = "az-1"
  single_ip_snat    = false
  manage_ha_gateway = false
  enable_bgp        = true
  local_as_number   = 65202
}

output "spoke1_vnet_id" {
  value = aviatrix_vpc.vnet_spoke1.vpc_id
}

output "spoke-gw1-name" {
  value = aviatrix_spoke_gateway.spoke_gw1.gw_name
}

# Create an Aviatrix Spoke Transit Attachment
resource "aviatrix_spoke_transit_attachment" "spoke1_attachment" {
  spoke_gw_name   = aviatrix_spoke_gateway.spoke_gw1.gw_name
  transit_gw_name = aviatrix_transit_gateway.transit_gw1.gw_name
#   route_tables    = [
#     "rtb-737d540c",
#     "rtb-626d045c"
#   ]
  depends_on = [
  aviatrix_spoke_gateway.spoke_gw1,
  aviatrix_transit_gateway.transit_gw1
  ]
}