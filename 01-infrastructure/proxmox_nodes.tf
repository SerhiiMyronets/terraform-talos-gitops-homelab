// ==============================================================================
// Talos Proxmox Image Download
// ==============================================================================

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = var.proxmox_node_name
  file_name               = "talos-${var.talos_version}.img"
  url                     = replace(data.talos_image_factory_urls.this.urls.disk_image, ".xz", ".gz")
  decompression_algorithm = "gz"
  overwrite               = true
  overwrite_unmanaged     = true
}

// ==============================================================================
// Talos Control Plane Virtual Machines
// ==============================================================================

resource "proxmox_virtual_environment_vm" "control_plane" {
  count           = var.controller_config.count
  vm_id           = count.index + 100
  name            = "${var.prefix}-${local.controller_nodes[count.index].name}"
  tags            = sort(["talos", "control_plane", "terraform"])
  stop_on_destroy = true
  node_name       = var.proxmox_node_name
  on_boot         = true

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = var.controller_config.cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.controller_config.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.proxmox_network_bridge
  }

  disk {
    datastore_id = var.controller_config.os_disk.datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.controller_config.os_disk.size
    iothread     = true
    ssd          = true
    discard      = "on"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.controller_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
}

// ==============================================================================
// Talos Worker Virtual Machines
// ==============================================================================

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [proxmox_virtual_environment_vm.control_plane]
  count      = var.worker_config.count
  name       = "${var.prefix}-${local.worker_nodes[count.index].name}"
  tags       = sort(["talos", "worker", "terraform"])
  node_name  = var.proxmox_node_name
  on_boot    = true

  scsi_hardware = "virtio-scsi-single"

  cpu {
    cores = var.worker_config.cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_config.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.proxmox_network_bridge
  }

  # OS disk (bootable Talos image)
  disk {
    datastore_id = var.worker_config.os_disk.datastore
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    size         = var.worker_config.os_disk.size
    iothread     = true
    ssd          = true
    discard      = "on"
  }
  #
  # Data disk for OpenEBS LocalPV
  disk {
    datastore_id = var.worker_config.open_ebs_disk.datastore
    interface    = "scsi1"
    file_format  = "raw"
    size         = var.worker_config.open_ebs_disk.size
    ssd          = true
    discard      = "on"
    iothread     = true
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.worker_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
}
