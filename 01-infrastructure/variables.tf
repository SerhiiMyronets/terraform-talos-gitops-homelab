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
  default     = "v1.10.5"
}

variable "talos_qemu_iscsi_hash" {
  description = "SHA256 hash of the Talos Linux image for QEMU/ISCSI."
  type        = string
  default     = "dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586"
}

locals {
  talos_image_url      = "https://factory.talos.dev/image/${var.talos_qemu_iscsi_hash}/${var.talos_version}/nocloud-amd64.raw.gz"
  talos_image_filename = "talos-${var.talos_version}-nocloud-amd64.img"
}

variable "kubernetes_version" {
  type    = string
  default = "1.32.0"
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

variable "load_balancer_ip_range" {
  description = "Range of host numbers to allocate for LoadBalancer services."
  default = {
    first = 80
    last  = 85
  }
}

// ==============================================================================
// Node Resource Configuration
// ==============================================================================

variable "controller_config" {
  description = "Resources for control plane nodes."
  type = object({
    count          = number
    cpu            = number
    memory         = number
    os_disk = object({
      size      = number
      datastore = string
    })
  })
  default = {
    count          = 3
    cpu            = 2
    memory         = 1024 * 6

    os_disk = {
      size      = 20
      datastore = "local-lvm"
    }
  }
}

variable "worker_config" {
  description = "Resources for worker nodes."
  type = object({
    count     = number
    cpu       = number
    memory    = number
    os_disk = object({
      size      = number
      datastore = string
    })
    longhorn_disk = object({
      size      = number
      datastore = string
    })
  })
  default = {
    count  = 2
    cpu    = 6
    memory = 1024 * 20

    os_disk = {
      size      = 20
      datastore = "local-lvm"
    }

    longhorn_disk = {
      size      = 40
      datastore = "local-lvm"
    }
  }
}