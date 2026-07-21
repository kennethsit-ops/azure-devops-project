module "linux_vms" {
  source   = "./modules/linux-vm"
  for_each = local.linux_vms
  
  vm_name        = each.value.vm_name
  nic_name       = each.value.nic_name
  public_ip_name = each.value.public_ip_name
  vm_size        = each.value.vm_size

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id

  admin_username = var.admin_username

  ssh_public_key = file(
    pathexpand("~/.ssh/id_rsa.pub")
  )

  custom_data = base64encode(
    templatefile("${path.module}/scripts/cloud-init.yaml.tftpl", {
      admin_username = var.admin_username
    })
  )

  tags               = local.common_tags
}