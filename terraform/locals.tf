locals {
  common_tags = {
    Environment = upper(var.environment)
    ManagedBy   = "Kenneth Sit"
    Project     = "Kenneth Sit DevOps Project"
    Owner       = "Kenneth Sit"
  }


  linux_vms = {
    for role, config in var.linux_vms :
    role => {
      vm_name          = "${var.environment}-${role}-01"
      nic_name         = "${var.environment}-${role}-01-nic"
      public_ip_name   = "${var.environment}-${role}-01-pip"
      vm_size          = config.vm_size
      enable_public_ip = config.enable_public_ip

    }
  }
}