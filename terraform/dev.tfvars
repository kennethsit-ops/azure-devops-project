environment         = "dev"
location            = "East US"
resource_group_name = "rg-demo-dev"

# vnet_address_space = [
#   "10.10.0.0/16"
# ]

# subnet_address_prefix = [
#   "10.10.1.0/24"
# ]

network_resource_group_name = "rg-shared-network-dev"
existing_vnet_name          = "vnet-shared-dev"
existing_subnet_name        = "snet-dev"


admin_username = "azuruser"


linux_vms = {
  web = { #this becomes the role in locals.tf
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = true
  }

  app = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = true
  }
}