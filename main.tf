locals {
  scripts_dir = "${path.module}/scripts"
  talos_ovf_url = "https://github.com/talos-systems/talos/releases/download/${var.talos_version}/vmware-amd64.ova"
  # Iterate through the different node types and combine to a single node value
  worker_specs = [
    for i in range(var.worker_nodes) : {
      ip_address = "${var.ip_address_base}.${var.worker_ip_address_start + i}"
      name = "${var.worker_name_prefix}-${i + 1}"
      cpus = var.worker_cpu
      memory = var.worker_memory
      disk_size = var.worker_disk_size
      config = base64encode(templatefile("${path.module}/talosnode.tpl", {
        type                        = "join"
        talos_token                 = var.talos_token
        talos_crt                   = var.talos_crt
        talos_key                   = var.talos_key
        talos_version               = var.talos_version
        customize_network           = var.customize_network
        node_ip_address             = "${var.ip_address_base}.${var.worker_ip_address_start + i}"
        ip_netmask                  = var.ip_netmask
        ip_gateway                  = var.ip_gateway
        nameservers                 = var.nameservers
        hostname                    = "${var.worker_name_prefix}-${i + 1}"
        tf_interface                = "eth0"
        tf_node_fqdn                = "${var.worker_name_prefix}-${i + 1}.${var.dns_domain}"
        add_extra_node_disk         = var.add_extra_node_disk
        kube_cluster_name           = var.kube_cluster_name
        tf_talos_version            = var.talos_version
        cluster_endpoint            = var.talos_cluster_endpoint
        talos_cluster_endpoint_port = var.talos_cluster_endpoint_port
        kube_dns_domain             = var.kube_dns_domain
        kube_token                  = var.kube_token
        kube_enc_key                = var.kube_enc_key
        kube_crt                    = var.kube_crt
        kube_key                    = var.kube_key
        etcd_crt                    = var.etcd_crt
        etcd_key                    = var.etcd_key
        tf_allow_master_scheduling  = var.allow_master_scheduling
        custom_cni                  = var.custom_cni
        cni_urls                    = var.cni_urls
      }))
    }
  ]
  controlplane_specs = [
    for i in range(var.controlplane_nodes) : {
      ip_address = "${var.ip_address_base}.${var.controlplane_ip_address_start + i}"
      name = "${var.controlplane_name_prefix}-${i + 1}"
      type = i == 0 ? "init" : "controlplane"
      cpus = var.controlplane_cpu
      memory = var.controlplane_memory
      disk_size = var.controlplane_disk_size
      config = base64encode(templatefile("${path.module}/talosnode.tpl", {
        type                        = i == 0 ? "init" : "controlplane"
        talos_token                 = var.talos_token
        talos_crt                   = var.talos_crt
        talos_key                   = var.talos_key
        customize_network           = var.customize_network
        node_ip_address             = "${var.ip_address_base}.${var.controlplane_ip_address_start + i}"
        ip_netmask                  = var.ip_netmask
        ip_gateway                  = var.ip_gateway
        nameservers                 = var.nameservers
        hostname                    = "${var.controlplane_name_prefix}-${i + 1}"
        tf_interface                = "eth0"
        tf_node_fqdn                = "${var.controlplane_name_prefix}-${i + 1}.${var.dns_domain}"
        add_extra_node_disk         = var.add_extra_node_disk
        kube_cluster_name           = var.kube_cluster_name
        tf_talos_version            = var.talos_version
        cluster_endpoint            = var.talos_cluster_endpoint
        talos_cluster_endpoint_port = var.talos_cluster_endpoint_port
        kube_dns_domain             = var.kube_dns_domain
        kube_token                  = var.kube_token
        kube_enc_key                = var.kube_enc_key
        kube_crt                    = var.kube_crt
        kube_key                    = var.kube_key
        etcd_crt                    = var.etcd_crt
        etcd_key                    = var.etcd_key
        tf_allow_master_scheduling  = var.allow_master_scheduling
        custom_cni                  = var.custom_cni
        cni_urls                    = var.cni_urls
      }))
    }
  ]
  node_specs = concat(local.worker_specs, local.controlplane_specs)
}
# ----------------------------------------------------------------------------
#   vSphere resources
# ----------------------------------------------------------------------------
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
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Generate the talosconfig file
#TODO: add all controlplane endpoints
resource "local_file" "talosconfig" {
  content = templatefile("${path.module}/talosconfig.tpl", {
    talos_cluster_endpoint = var.talos_cluster_endpoint
    talos_cluster_name     = var.talos_cluster_name
    tf_endpoints           = var.talos_cluster_endpoint
    nodes                  = local.controlplane_specs[0].ip_address
    # tf_endpoints           = local.controlplane_specs[0].ip_address
    tf_talos_ca_crt        = var.talos_crt
    tf_talos_admin_crt     = var.admin_crt
    tf_talos_admin_key     = var.admin_key
  })
  filename = "${abspath(var.talos_config_path)}/talosconfig"
}

# ----------------------------------------------------------------------------
#   Talos Nodes
# ----------------------------------------------------------------------------
resource "vsphere_virtual_machine" "controlplane" {
  count                      = length(local.controlplane_specs)
  name                       = local.controlplane_specs[count.index].name
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  host_system_id             = data.vsphere_host.host.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.datacenter.id
  wait_for_guest_net_timeout = -1 # don't wait for guest since talos doesn't have vmtools
  num_cpus = local.controlplane_specs[count.index].cpus
  memory   = local.controlplane_specs[count.index].memory
  ovf_deploy {
    remote_ovf_url = local.talos_ovf_url
  }

  # Disk
  disk {
    name = var.ova_disk_name
    size = local.controlplane_specs[count.index].disk_size
  }

  # Additional disk
  dynamic "disk" {
    for_each = var.node_extra_disk

    content {
      label = "extra_disk_${disk.key + 1}.vmdk"
      size = disk.value.size
      unit_number = (disk.key + 1)
      thin_provisioned = true
    }
  }

  # VM networking
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = var.vsphere_nic_type
  }

  # for vsphere-kubernetes integration
  enable_disk_uuid = "true"

  # sets the talos configuration
  extra_config = {
    "guestinfo.talos.config" = local.controlplane_specs[count.index].config
  }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      disk[1].io_share_count,
      disk[1].io_share_count
    ]
  }
}

resource "vsphere_virtual_machine" "worker" {
  count                      = length(local.worker_specs)
  name                       = local.worker_specs[count.index].name
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  host_system_id             = data.vsphere_host.host.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.datacenter.id
  wait_for_guest_net_timeout = -1 # don't wait for guest since talos doesn't have vmtools
  num_cpus = local.worker_specs[count.index].cpus
  memory   = local.worker_specs[count.index].memory
  ovf_deploy {
    remote_ovf_url = local.talos_ovf_url
  }

  # Disk
  disk {
    name = var.ova_disk_name
    size = local.worker_specs[count.index].disk_size
  }

  # Additional disk
  dynamic "disk" {
    for_each = var.node_extra_disk

    content {
      label = "extra_disk_${disk.key + 1}.vmdk"
      size = disk.value.size
      unit_number = (disk.key + 1)
      thin_provisioned = true
    }
  }

  # VM networking
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = var.vsphere_nic_type
  }

  # for vsphere-kubernetes integration
  enable_disk_uuid = "true"

  # sets the talos configuration
  extra_config = {
    "guestinfo.talos.config" = local.worker_specs[count.index].config
  }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      disk[1].io_share_count,
      disk[1].io_share_count
    ]
  }
}