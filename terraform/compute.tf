module "linux_vms" {
  source   = "./modules/linux-vm"
  for_each = local.linux_vms

  vm_name          = each.value.vm_name
  nic_name         = each.value.nic_name
  public_ip_name   = each.value.public_ip_name
  vm_size          = each.value.vm_size
  enable_public_ip = each.value.enable_public_ip

  network_security_group_id = azurerm_network_security_group.web.id
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  subnet_id                 = data.azurerm_subnet.existing.id

  admin_username = var.admin_username

  ssh_public_key = var.ssh_public_key

  custom_data = base64encode(
    templatefile("${path.module}/scripts/cloud-init.yaml.tftpl", {
      admin_username = var.admin_username
    })
  )

  tags = local.common_tags
}