# Create an OCI VPC
resource "aviatrix_vpc" "oci_vpc" {
  cloud_type   = 16
  account_name = var.OCIACCESSACCOUNT
  region       = var.OCIREGION
  name         = "oci-vpc-${random_id.id.hex}"
  cidr         = "10.6.0.0/20"
}

output "oci_vpc" {
  value = aviatrix_vpc.oci_vpc.vpc_id
}

# Create an Aviatrix OCI Transit Network Gateway
resource "aviatrix_transit_gateway" "transit_gw_oci" {
  cloud_type          = 16
  account_name        = var.OCIACCESSACCOUNT
  gw_name             = "avx-oci-transit-${random_id.id.hex}"
  vpc_id              = aviatrix_vpc.oci_vpc.vpc_id
  vpc_reg             = var.OCIREGION
  gw_size             = "VM.Standard2.2"
  subnet              = aviatrix_vpc.oci_vpc.subnets[0].cidr
  availability_domain = aviatrix_vpc.oci_vpc.availability_domains[0]
  fault_domain        = aviatrix_vpc.oci_vpc.fault_domains[0]
  local_as_number     = 65203
  connected_transit   = true
}

# Create an Aviatrix Transit Gateway Peering
resource "aviatrix_transit_gateway_peering" "oci_transit_gateway_peering" {
  transit_gateway_name1                       = aviatrix_transit_gateway.transit_gw_oci.gw_name
  transit_gateway_name2                       = aviatrix_transit_gateway.transit_gw1.gw_name
#   gateway1_excluded_network_cidrs             = ["10.0.0.48/28"]
#   gateway2_excluded_network_cidrs             = ["10.0.0.48/28"]
#   gateway1_excluded_tgw_connections           = ["vpn_connection_a"]
#   gateway2_excluded_tgw_connections           = ["vpn_connection_b"]
#   prepend_as_path1                            = [
#     "65001",
#     "65001",
#     "65001"
#   ]
#   prepend_as_path2                            = [
#     "65002"
#   ]
  enable_peering_over_private_network         = false
  enable_insane_mode_encryption_over_internet = false

  depends_on = [
    aviatrix_transit_gateway.transit_gw_oci,
    aviatrix_transit_gateway.transit_gw1
  ]
}

output "oci_transit_gw_name" {
    value = aviatrix_transit_gateway.transit_gw_oci.gw_name
}
