# Control plane nodes
resource "vsphere_virtual_machine" "node" {
  # Control Plane Count
  count                      = length(local.node_specs)
  name                       = local.node_specs[count.index].name
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  host_system_id             = data.vsphere_host.host.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.datacenter.id
  wait_for_guest_net_timeout = -1
  #tags
  #folder
  num_cpus = local.node_specs[count.index].cpus
  memory   = local.node_specs[count.index].memory
  ovf_deploy {
    remote_ovf_url = local.talos_ovf_url
  }

  # Disk
  disk {
    name = var.ova_disk_name
    size = var.controlplane_disk_size
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
      type                       = local.node_specs[count.index].type
      talos_token                = var.talos_token
      talos_crt                  = var.talos_crt
      talos_key                  = var.talos_key
      customize_network          = var.customize_network
      node_ip_address            = local.node_specs[count.index].ip_address
      ip_netmask                 = var.ip_netmask
      ip_gateway                 = var.ip_gateway
      nameservers                = var.nameservers
      tf_kube_version            = var.kube_version
      hostname                   = local.node_specs[count.index].name
      tf_interface               = "eth0"
      tf_network                 = "${var.ip_address_base}.0"
      tf_node_fqdn               = "${local.node_specs[count.index].name}.${var.dns_domain}"
      tf_os_disk                 = "/dev/sda"
      tf_add_disks               = var.add_disks
      tf_extra_disks             = var.extra_disks
      tf_add_registries          = var.add_registries
      tf_registries              = var.registries
      kube_cluster_name          = var.kube_cluster_name
      tf_talos_version           = var.talos_version
      cluster_endpoint           = var.talos_cluster_endpoint
      kube_dns_domain            = var.kube_dns_domain
      kube_token                 = var.kube_token
      kube_enc_key               = var.kube_enc_key
      kube_crt                   = var.kube_crt
      kube_key                   = var.kube_key
      etcd_crt                   = var.etcd_crt
      etcd_key                   = var.etcd_key
      tf_allow_master_scheduling = var.allow_master_scheduling
      custom_cni                 = var.custom_cni
      cni_type                   = var.cni_type
      cni_urls                   = var.cni_urls
    }))
  }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
    ]
  }
}