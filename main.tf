locals {
  scripts_dir = "${path.module}/scripts"
  talos_ovf_url = "https://github.com/talos-systems/talos/releases/download/${var.talos_version}/vmware-amd64.ova"
  # Iterate through the different node types and combine to a single node value
  worker_specs = [
    for i in range(var.worker_nodes) : {
      ip_address = "${var.ip_address_base}.${var.worker_ip_address_start + i}"
      name = "${var.worker_name_prefix}-${i + 1}"
      type = "join"
      cpus = var.worker_cpu
      memory = var.worker_memory
    }
  ]
  controlplane_specs = [
    for i in range(var.controlplane_nodes) : {
      ip_address = "${var.ip_address_base}.${var.controlplane_ip_address_start + i}"
      name = "${var.controlplane_name_prefix}-${i + 1}"
      type = i == 0 ? "init" : "controlplane"
      cpus = var.controlplane_cpu
      memory = var.controlplane_memory
    }
  ]
  node_specs = concat(local.worker_specs, local.controlplane_specs)
  # controlplane_ips = local.controlplane_specs.*.ip_address
}
output "ips" {
  value = tolist(local.controlplane_specs.*.ip_address)
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

# Generate the talosconfig file
#TODO: iterate this
resource "local_file" "talosconfig" {
  content = templatefile("${path.module}/talosconfig.tpl", {
    talos_cluster_endpoint = var.talos_cluster_endpoint
    talos_cluster_name     = var.talos_cluster_name
    tf_endpoints           = local.controlplane_specs[0].ip_address
    tf_talos_ca_crt        = var.talos_crt
    tf_talos_admin_crt     = var.admin_crt
    tf_talos_admin_key     = var.admin_key
  })
  filename = "${abspath(var.conf_dir)}/talosconfig"
}

# resource "local_file" "initconfig" {
#   content = templatefile("./talosnode.tpl", {
#       type              = "init"
#     #   talos_join_token  = var.talos_join_token
#       talos_join_token  = format("%s.%s", substr(random_string.random_token[0].result, 7, 6), substr(random_string.random_token[0].result, 17, 16))
#     #   talos_ca_crt      = var.talos_ca_crt
#       talos_ca_crt      = data.external.talos_certificates.result.talos_crt
#     #   talos_ca_key      = var.talos_ca_key
#       talos_ca_key      = data.external.talos_certificates.result.talos_key
#       customize_network = var.customize_network
#       node_ip_address   = "${var.ip_address_base}.${var.controlplane_ip_address_start}"
#       ip_netmask        = var.ip_netmask
#       ip_gateway        = var.ip_gateway
#       nameservers       = var.nameservers
#       tf_kube_version   = var.kube_version
#       hostname          = "${var.controlplane_name_prefix}-1"
#       tf_interface      = "eth0"
#       tf_network        = "${var.ip_address_base}.0"
#       tf_node_fqdn      = "${var.controlplane_name_prefix}-1.${var.dns_domain}"
#       tf_os_disk        = "/dev/sda"
#       #TODO: add ability to add extra_disks
#       #TODO: add ability to add extra registries
#       tf_add_disks               = var.add_disks
#       tf_extra_disks             = var.extra_disks
#       tf_add_registries          = var.add_registries
#       tf_registries              = var.registries
#       kube_cluster_name          = var.kube_cluster_name
#       tf_talos_version           = var.talos_version
#       cluster_endpoint           = format("%s.%s", var.kube_cluster_name, var.dns_domain)
#       kube_dns_domain            = var.kube_dns_domain
#       kube_token                 = format("%s.%s", substr(random_string.random_token[1].result, 5, 6), substr(random_string.random_token[1].result, 15, 16))
#       kube_enc_key               = base64encode(random_string.random_key[0].result)
#       kube_ca_crt                = data.external.talos_certificates.result.kube_crt
#       kube_ca_key                = data.external.talos_certificates.result.kube_key
#       etcd_ca_crt                = data.external.talos_certificates.result.etcd_crt
#       etcd_ca_key                = data.external.talos_certificates.result.etcd_key
#       tf_allow_master_scheduling = var.allow_master_scheduling
#     })
#   filename = "${abspath(var.conf_dir)}/init.yaml"

#   depends_on = [data.external.talos_certificates]
# }

# output "talos_ca_crt" {
#   value = data.external.talos_certificates.result.talos_crt
# }