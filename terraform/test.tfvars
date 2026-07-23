environment = "test"

location = "East US"

resource_group_name = "rg-demo-test"

network_resource_group_name = "rg-shared-network-test"
existing_vnet_name          = "vnet-shared-test"
existing_subnet_name        = "snet-test"

admin_username = "azuruser"

linux_vms = {

  web = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = true
  }

  app = {
    vm_size          = "Standard_D2s_v7"
    enable_public_ip = true
  }

}