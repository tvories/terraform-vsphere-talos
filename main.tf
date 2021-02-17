// Populate the info for the individual nodes
//TODO: Would love to figure out how to make the below work
// locals {
//   # Control plane nodes for IP and name creation
//   controlplane_conf = flatten([
//     for node in var.controlplane_nodes : {
//       name = "${var.controlplane_name_prefix}-${node + 1}"
//       ip = "${var.ip_address_base}.${var.controlplane_ip_address_start + node}"
//       type = cp == 0 ? "init" : "controlplane"
//     }
//   ])
//   worker_conf = flatten([
//     for node in var.worker_nodes : {
//       name = "${var.worker_name_prefix}-${node + 1}"
//       ip = "${var.ip_address_base}.${var.worker_ip_address_start + node}"
//       type = "join"
//     }
//   ])
// }

locals {
  talos_config_raw = yamldecode(file(var.talos_config_path))
  talos_cluster_name = local.talos_config_raw.context
  // talos_
}

output "talos_config" {
  value = local.talos_config_raw
}
output "talos_context" {
  value = local.tconf_context
}

// vCenter specific settings
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_resource_pool" "resource_pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

// Network
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

// Generate the talosconfig file if needed