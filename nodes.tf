# Control plane nodes
resource "vsphere_virtual_machine" "controlplane" {
  # Control Plane Count
  count                      = var.controlplane_nodes
  name                       = "${var.controlplane_name_prefix}-${count.index + 1}" #TODO: figure out how to calculate this once
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  host_system_id             = data.vsphere_host.host.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.datacenter.id
  wait_for_guest_net_timeout = -1
  #tags
  #folder
  num_cpus = var.controlplane_cpu
  memory   = var.controlplane_memory
  ovf_deploy {
    remote_ovf_url = local.talos_ovf_url
  }

  # Disk
  disk {
    name = var.controlplane_disk_name
    size = var.controlplane_disk_size
    // thin_provisioned = var.controlplane_disk_thin
  }

  # VM networking #
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = var.vsphere_nic_type
  }

  # for vsphere-kubernetes integration
  enable_disk_uuid = "true"

  # sets the talos configuration #TODO: figure out how to combine worker and cp nodes
  extra_config = {
    "guestinfo.talos.config" = base64encode(templatefile("./talosnode.tpl", {
      type              = count.index == 0 ? "init" : "controlplane"
    #   talos_join_token  = var.talos_join_token
      talos_join_token  = format("%s.%s", substr(random_string.random_token[0].result, 7, 6), substr(random_string.random_token[0].result, 17, 16))
    #   talos_ca_crt      = var.talos_ca_crt
      talos_ca_crt      = data.external.talos_certificates.result.talos_crt
    #   talos_ca_key      = var.talos_ca_key
      talos_ca_key      = data.external.talos_certificates.result.talos_key
      customize_network = var.customize_network
      node_ip_address   = "${var.ip_address_base}.${var.controlplane_ip_address_start + count.index}"
      ip_netmask        = var.ip_netmask
      ip_gateway        = var.ip_gateway
      nameservers       = var.nameservers
      tf_kube_version   = var.kube_version
      hostname          = "${var.controlplane_name_prefix}-${count.index + 1}"
      tf_interface      = "eth0"
      tf_network        = "${var.ip_address_base}.0"
      tf_node_fqdn      = "${var.controlplane_name_prefix}-${count.index + 1}.${var.dns_domain}"
      tf_os_disk        = "/dev/sda"
      #TODO: add ability to add extra_disks
      #TODO: add ability to add extra registries
      tf_add_disks               = var.add_disks
      tf_extra_disks             = var.extra_disks
      tf_add_registries          = var.add_registries
      tf_registries              = var.registries
      kube_cluster_name          = var.kube_cluster_name
      tf_talos_version           = var.talos_version
      cluster_endpoint           = format("%s.%s", var.kube_cluster_name, var.dns_domain)
      kube_dns_domain            = var.kube_dns_domain
      kube_token                 = format("%s.%s", substr(random_string.random_token[1].result, 5, 6), substr(random_string.random_token[1].result, 15, 16))
      kube_enc_key               = base64encode(random_string.random_key[0].result)
      kube_ca_crt                = data.external.talos_certificates.result.kube_crt
      kube_ca_key                = data.external.talos_certificates.result.kube_key
      etcd_ca_crt                = data.external.talos_certificates.result.etcd_crt
      etcd_ca_key                = data.external.talos_certificates.result.etcd_key
      tf_allow_master_scheduling = var.allow_master_scheduling
    }))
  }
  # extra_config = {
  #   "guestinfo.talos.config" = filebase64("./${count.index == 0 ? "init" : "controlplane"}.yaml")
  # }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
    ]
  }
}

output "controlplane_config" {
  description = "This is the value of the guestinfo.talos.config for the controlplane nodes"
  // value = { for vm in vsphere_virtual_machine.controlplane : vm => vsphere_virtual_machine.controlplane[vm].extra_config }
  value = vsphere_virtual_machine.controlplane.*.extra_config
}