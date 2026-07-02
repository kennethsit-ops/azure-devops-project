# Linux VM Validation

## Purpose

Validate that the Terraform-provisioned Ubuntu VM is accessible and healthy.

## Commands Used

```bash
hostname
hostnamectl
cat /etc/os-release
free -h
df -h
ip addr
sudo apt update