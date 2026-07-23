environment = "prod"

location = "East US"

resource_group_name = "rg-demo-prod"

network_resource_group_name = "rg-shared-network-prod"
existing_vnet_name          = "vnet-shared-prod"
existing_subnet_name        = "snet-prod"

admin_username = "azuruser"

linux_vms = {

  web = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = false
  }

  app = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = false

  }

  jumpbox = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = false

  }

}