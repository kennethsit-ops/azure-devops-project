module "web_vm" {

  source = "./modules/linux-vm"

  public_ip_name      = var.public_ip_name_web
  nic_name            = var.nic_name_web
  vm_name             = var.vm_name_web
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.web.id
  vm_size             = var.vm_size_web
  admin_username      = var.admin_username

  ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  custom_data = base64encode(
    templatefile("${path.module}/scripts/cloud-init.yaml.tftpl", {
      admin_username = var.admin_username
    })
  )
}