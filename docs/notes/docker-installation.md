# Docker Installation on Azure Linux VM

## Purpose

Install and validate Docker on the Terraform-provisioned Ubuntu VM.

## Commands

```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker azureuser
docker --version
docker run hello-world