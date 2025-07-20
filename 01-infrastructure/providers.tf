// ==============================================================================
// Terraform Settings
// ==============================================================================

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.0-alpha.0"
    }
  }
  backend "s3" {
    bucket = "serhii-myronets"
    key    = "homelab/cluster.tfstate"
    region = "us-east-1"
  }
}

// ==============================================================================
// Proxmox Provider
// ==============================================================================

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}