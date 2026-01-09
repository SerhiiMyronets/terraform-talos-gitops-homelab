// ==============================================================================
// Local Definitions for Node IPs
// ==============================================================================

locals {
  controller_nodes = [
    for i in range(var.controller_config.count) : {
      name    = "controlplane-0${i + 1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_controller_hostnum + i)
    }
  ]

  worker_nodes = [
    for i in range(var.worker_config.count) : {
      name    = "worker-0${i + 1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_worker_hostnum + i)
    }
  ]
}

// ==============================================================================
// Local Definitions for Patch Files
// ==============================================================================

locals {
  patch_base_path = "${path.module}/patches"

  common_patch_files     = fileset("${local.patch_base_path}/common", "*.yaml")
  worker_patch_files     = fileset("${local.patch_base_path}/worker", "*.yaml")
  controller_patch_files = fileset("${local.patch_base_path}/controller", "*.yaml")

  shared_patches = [
    for f in local.common_patch_files :
    yamlencode(yamldecode(file("${local.patch_base_path}/common/${f}")))
  ]

  worker_patches = [
    for f in local.worker_patch_files :
    yamlencode(yamldecode(file("${local.patch_base_path}/worker/${f}")))
  ]

  controller_patches = [
    for f in local.controller_patch_files :
    yamlencode(yamldecode(templatefile("${local.patch_base_path}/controller/${f}", { cluster_vip = var.cluster_vip })))
  ]

  config_patches_worker = concat(
    local.shared_patches,
    local.worker_patches
  )

  config_patches_controller = concat(
    local.shared_patches,
    local.controller_patches,
  )
}

resource "local_file" "cilium_lb_pool_manifest" {
  filename = "${path.module}/../02-bootstrap/manifests/cleanup/cilium-lb-pool.yaml"
  content = templatefile("${path.module}/../02-bootstrap/manifests/templates/cilium-lb-pool.yaml.tftpl", {
    load_balancer_first_host = cidrhost(var.cluster_node_network, var.load_balancer_ip_range.first),
    load_balancer_last_host  = cidrhost(var.cluster_node_network, var.load_balancer_ip_range.last)
  })
}