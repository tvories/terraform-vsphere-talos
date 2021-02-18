// vSphere variables
variable "vsphere_user" {
  description = "vSphere user name"
  type        = string
}
variable "vsphere_password" {
  description = "vSphere password"
  sensitive   = true
  type        = string
}
variable "vsphere_vcenter" {
  description = "vCenter server FQDN or IP"
  type        = string
}
variable "vsphere_unverified_ssl" {
  description = "Allow unverified SSL connection to vSphere?"
  type        = bool
  default     = false
}
variable "vsphere_datacenter" {
  description = "In which datacenter the VM will be deployed"
  type        = string
}
variable "vsphere_resource_pool" {
  description = "VM Resource Pool"
  type        = string
}
variable "vsphere_host" {
  description = "The host to deploy to"
  type        = string
}
variable "vsphere_cluster" {
  description = "In which cluster the VM will be deployed"
  type        = string
}
variable "vsphere_datastore" {
  description = "What is the name of the VM datastore"
  type        = string
}
variable "vsphere_network" {
  description = "What is the name of the VM Network?"
  type        = string
}
// variable "talos_ovf_url" {
//   description = "URL to the talos ovf file"
// }

// Talos settings
variable "talos_version" {
  description = "The version of Talos OS, used for building the cluster; the version string should start with 'v'"
  type        = string
  default     = "v0.8.3"

  validation {
    condition     = var.talos_version != "" && substr(var.talos_version, 0, 1) == "v"
    error_message = "The specified Talos version is invalid."
  }
}
variable "talos_cli_update" {
  description = "Whether Talos CLI (talosctl) should be installed/updated or not, for the specified Talos version (default is true)"
  type        = bool
  default     = true
}

// Kubernetes settings
variable "kube_version" {
  description = "The version of Kubernetes (e.g. 1.20); default is the latest version supported by the selected Talos version"
  type        = string
  default     = ""
}
variable "kube_cluster_name" {
  description = "The Kubernetes cluster name (default is talos)"
  type        = string
  default     = "talos"

  validation {
    condition     = var.kube_cluster_name != ""
    error_message = "The Kubernetes cluster name must be identified."
  }
}
variable "kube_dns_domain" {
  description = "The Kubernetes cluster DNS domain (default is cluster.local)"
  type        = string
  default     = "cluster.local"

  validation {
    condition     = var.kube_dns_domain != ""
    error_message = "The Kubernetes cluster DNS domain must be identified."
  }
}

// Control plane systems
variable "controlplane_nodes" {
  description = "Number of control plane servers"
  type        = number
  default     = 1

  validation {
    condition     = var.controlplane_nodes == 1 || var.controlplane_nodes == 3
    error_message = "Number of control plane nodes must be either one, or three (HA cluster)."
  }
}
variable "controlplane_name_prefix" {
  description = "Name prefix for control plane servers (IE talos-cp)"
  type        = string
  default     = "talos-cp"
}
variable "controlplane_cpu" {
  description = "Number of CPU for Controlplane systems"
  type        = number
  default     = 2
}
variable "controlplane_memory" {
  description = "Memory in MB for Controlplane systems"
  type        = number
  default     = 2048
}
variable "controlplane_disk_name" {
  description = "The name of the OVA disk"
  type        = string
  default     = "disk-1000-0.vmdk"
}
variable "controlplane_disk_size" {
  description = "Size in GB of the control plane disk"
  type        = number
  default     = 8
}
variable "controlplane_disk_thin" {
  description = "Thin provision controlplane disk?"
  type        = bool
  default     = true
}

# Worker systems
variable "worker_nodes" {
  description = "Number of control plane servers"
  type        = number
  default     = 1
}
variable "worker_name_prefix" {
  description = "Name prefix for control plane servers (IE talos-worker)"
  type        = string
  default     = "talos-worker"
}
variable "worker_cpu" {
  description = "Number of CPU for worker nodes"
  type        = number
  default     = 2
}
variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 2
}
variable "worker_disk_name" {
  description = "The name of the OVA disk"
  type        = string
  default     = "disk-1000-0.vmdk"
}
variable "worker_disk_size" {
  description = "Size in GB of the worker disk"
  type        = number
  default     = 8
}
variable "worker_disk_thin" {
  description = "Thin provision worker disk?"
  type        = bool
  default     = true
}

# Networking
variable "vsphere_nic_type" {
  description = "NIC type (vmxnet3 or e1000)"
  type        = string
  default     = "e1000"

  validation {
    condition     = var.vsphere_nic_type != "vmxnet3" || var.vsphere_nic_type != "e1000"
    error_message = "Number of control plane nodes must be either one, or three (HA cluster)."
  }
}
variable "ip_gateway" {
  description = "The network gateway address IE: 192.168.1.1"
  type        = string

  validation {
    condition = var.ip_gateway != ""
    error_message = "Must define network gateway."
  }
}
variable "nameservers" {
  description = "The nameservers for the node NICs"
  type        = list(string)
  default     = ["1.1.1.1"]
}
variable "dns_domain" {
  description = "The DNS domain for the hostonly network; usually the domain host is part of"
  type        = string
  default     = ""

  validation {
    condition     = var.dns_domain != ""
    error_message = "The specified DNS domain is invalid, or is empty."
  }
}
#TODO: find a better way to manage the network
variable "ip_address_base" {
  description = "The base network/subnet IE: 192.168.1"
  type        = string

  validation {
    condition = var.ip_address_base != ""
    error_message = "Must provide base network."
  }
}
variable "ip_netmask" {
  description = "The network mask in /cidr notation form IE: /24"
  type        = string
  default     = "/24"
  //TODO: Add validation for netmask
}
variable "controlplane_ip_address_start" {
  description = "Don't overlap with worker_ip_address_start! The first control plane address IE: 100"
  type        = string
  // default     = "150"

  validation {
    condition = var.controlplane_ip_address_start != ""
    error_message = "You must provide a starting IP address for the controlplane nodes."
  }
}
variable "worker_ip_address_start" {
  description = "Don't overlap with controlplane_ip_address_start! The first worker address IE: 150"
  type        = string
  // default     = "180"

  validation {
    condition = var.worker_ip_address_start != ""
    error_message = "You must provide a starting IP address for the worker nodes."
  }
}
variable "customize_network" {
  description = "Whether or not to customize the node networks.  Uses DHCP if set to false."
  type        = bool
  default     = true
}

# Config vars
variable "shell" {
  description = "The qualified name of preferred shell (e.g. /bin/bash, /bin/zsh, /bin/sh...), to minimize risk of incompatibility (default is /bin/bash)"
  type        = string
  default     = "/bin/bash"

  validation {
    condition     = var.shell != ""
    error_message = "The shell, for exection of scripts, must be identified."
  }
}
# TODO: grab this from config file?
// Talos config
variable "talos_config_path" {
  description = <<EOT
      The full or relative path to the talos config file
      Full path: /home/user/talosconfig
      Relative path: ./config/talosconfig or ./talosconfig
    EOT
    type      = string
    default   = ""

    validation {
      condition   = var.talos_config_path != ""
      error_message = "Talos config file path must be provided."
    }
}
variable "conf_dir" {
  description = "The directory used for storing Talos ISO and cluster build configuration files (default is /tmp)"
  type        = string
  default     = "/tmp"

  validation {
    condition     = var.conf_dir != ""
    error_message = "The Talos configuration directory must be identified."
  }
}
variable "talos_ca_crt" {
  description = "talos ca cert"
}
variable "talos_ca_key" {
  description = "talos ca key"
}
variable "talos_join_token" {
  description = "Token used to join a system to the cluster"
  #TODO: Figure out a way to generate this sanely
}
variable "kube_enc_key" { #TODO: change to generated and get rid of this?
  description = "The key used for the encryption of secret data at rest"
}
variable "kube_token" {
  description = "The [bootstrap token](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/) used to join the cluster."
}
variable "kube_ca_crt" {
  description = "The base64 encoded root certificate authority cert used by Kubernetes."
}
variable "kube_ca_key" {
  description = "The base64 encoded root certificate authority key used by Kubernetes."
}
variable "etcd_ca_crt" {
  description = "The `ca` is the root certificate authority of the PKI."
}
variable "etcd_ca_key" {
  description = "The `ca` is the root certificate authority of the PKI."
}
variable "allow_master_scheduling" {
  description = "Allows running workload on master nodes."
  type        = string
  default     = "false"
}
variable "add_disks" {
  description = "Not sure on this"
  type        = bool
  default     = false
}
variable "extra_disks" {
  description = "Disks to add"
  default     = ""
}
variable "add_registries" {
  description = "Eventually will let you add registries"
  type        = bool
  default     = false
}
variable "registries" {
  description = "Registries to add"
  default     = ""
}

// TODO: Figure out how to do an object
// variable "controlplane_specs" {
//   description = "The vSphere VM specs used for building Talos cluster's control plane nodes (default is 2 CPU, 2GB RAM, and 8GB disk)"
//   type = object({
//     num_cpu      = number
//     memory  = number
//     disk_size = number
//   })
//   default = {
//     cpus      = 2
//     ram_size  = 2048
//     disk_size = 8000
//   }
// }