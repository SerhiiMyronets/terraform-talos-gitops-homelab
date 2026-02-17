// ==============================================================================
// Proxmox Credentials
// ==============================================================================

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL."
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox API username."
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox API password."
  type        = string
  sensitive   = true
}

// ==============================================================================
// Global Cluster Settings
// ==============================================================================

variable "cluster_name" {
  description = "The name of the Kubernetes cluster. Used in resource naming."
  type        = string
  default     = "homelab"
}

variable "prefix" {
  description = "Prefix used for virtual machine names."
  type        = string
  default     = "talos"
}

// ==============================================================================
// Proxmox Node Settings
// ==============================================================================

variable "proxmox_node_name" {
  description = "The name of the Proxmox node where virtual machines are created."
  type        = string
  default     = "proxmox"
}

variable "proxmox_network_bridge" {
  description = "The network bridge interface on Proxmox used by virtual machines."
  type        = string
  default     = "vmbr0"
}

// ==============================================================================
// Talos Settings
// ==============================================================================

variable "talos_version" {
  description = "Talos Linux version."
  type        = string
  default     = "v1.12.4"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34.2"
}

// ==============================================================================
// Cluster Network Settings
// ==============================================================================

variable "cluster_node_network" {
  description = "The CIDR block for the Kubernetes nodes network."
  type        = string
  default     = "10.1.1.0/24"
}

variable "cluster_node_network_gateway" {
  description = "The gateway IP address for the Kubernetes nodes network."
  type        = string
  default     = "10.1.1.1"
}

variable "cluster_vip" {
  description = "The Virtual IP used by controller nodes for the Kubernetes API (should be in same subnet)."
  type        = string
  default     = "10.1.1.50"
}

locals {
  cluster_endpoint = "https://${var.cluster_vip}:6443"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = "Host number for the first controlplane node (e.g. 192.168.100.60)."
  type        = number
  default     = 60
}

variable "cluster_node_network_first_worker_hostnum" {
  description = "Host number for the first worker node (e.g. 168.168.100.70)."
  type        = number
  default     = 70
}

// ==============================================================================
// Node Resource Configuration
// ==============================================================================

variable "controller_config" {
  description = "Resources for control plane nodes."
  type = object({
    count  = number
    cpu    = number
    memory = number
    os_disk = object({
      size      = number
      datastore = string
    })
  })
  default = {
    count  = 1
    cpu    = 4
    memory = 1024 * 6

    os_disk = {
      size      = 30
      datastore = "local-lvm"
    }
  }
}

variable "worker_config" {
  description = "Resources for worker nodes."
  type = object({
    count  = number
    cpu    = number
    memory = number
    os_disk = object({
      size      = number
      datastore = string
    })
    open_ebs_disk = object({
      size      = number
      datastore = string
    })
  })
  default = {
    count  = 3
    cpu    = 4
    memory = 1024 * 16

    os_disk = {
      size      = 20
      datastore = "local-lvm"
    }

    open_ebs_disk = {
      size      = 100
      datastore = "local-lvm"
    }
  }
}