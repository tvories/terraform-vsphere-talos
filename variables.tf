variable "vsphere_datacenter" {
  description = "In which datacenter the VM will be deployed"
  type        = string
  default     = ""

  validation {
    condition     = var.vsphere_datacenter != ""
    error_message = "You must specify the destination datacenter for the talos virtual machines."
  }
}
variable "vsphere_resource_pool" {
  description = "VM Resource Pool"
  type        = string
  default = ""

  validation {
    condition     = var.vsphere_resource_pool != ""
    error_message = "You must specify the destination resource pool."
  }
}
variable "vsphere_host" {
  description = "The host to deploy to"
  type        = string
  default = ""

  validation {
    condition     = var.vsphere_host != ""
    error_message = "You must specify the destination esxi host.  Hopefully this requirement will be removed in a future release."
  }
}
variable "vsphere_cluster" {
  description = "In which cluster the VM will be deployed"
  type        = string
  default = ""

  validation {
    condition     = var.vsphere_cluster != ""
    error_message = "You must specify the destination cluster."
  }
}
variable "vsphere_datastore" {
  description = "What is the name of the destination VM datastore"
  type        = string
  default = ""

  validation {
    condition     = var.vsphere_datastore != ""
    error_message = "You must specify the destination datastore."
  }
}
variable "vsphere_network" {
  description = "What is the name of the VM Network?"
  type        = string
  default = ""

  validation {
    condition     = var.vsphere_network != ""
    error_message = "You must specify the destination network."
  }
}

# Talos settings
variable "talos_version" {
  description = "The version of Talos OS, used for building the cluster; the version string should start with 'v'"
  type        = string
  default     = "v0.8.4"

  validation {
    condition     = var.talos_version != "" && substr(var.talos_version, 0, 1) == "v"
    error_message = "The specified Talos version is invalid."
  }
}
variable "talos_cluster_endpoint" {
  description = "The DNS or load balancer IP endpoint name IE talos.yourdomain.local"
  type = string
  default = ""

  validation {
    condition = var.talos_cluster_endpoint != ""
    error_message = "You must provide an endpoint DNS name or IP."
  }
}
variable "talos_cluster_endpoint_port" {
  description = "The port for the cluster endpoint.  Usually 6443 or 443 (behind loadbalancer)."
  type = string
  default = "6443"

  validation {
    condition     = var.talos_cluster_endpoint_port != ""
    error_message = "You must specify the endpoint port for the Talos cluster endpoint."
  }
}
variable "talos_cluster_name" {
  description = "The talosconfig cluster name used for context"
  type = string
  default = "talos"

  validation {
    condition = var.talos_cluster_name != ""
    error_message = "The talos_cluster_name cannot be blank."
  }
}

# Kubernetes settings
variable "kube_cluster_name" {
  description = "The Kubernetes cluster name (default is cluster.local)"
  type        = string
  default     = "cluster.local"

  validation {
    condition     = var.kube_cluster_name != ""
    error_message = "The Kubernetes cluster name must be identified."
  }
}
# TODO: Get rid of one of these
variable "kube_dns_domain" {
  description = "The Kubernetes cluster DNS domain (default is cluster.local)"
  type        = string
  default     = "cluster.local"

  validation {
    condition     = var.kube_dns_domain != ""
    error_message = "The Kubernetes cluster DNS domain must be identified."
  }
}
# Node config
variable "ova_disk_name" {
  description = "The name of the OVA disk"
  type        = string
  default     = "disk-1000-0.vmdk"

  validation {
    condition = var.ova_disk_name != ""
    error_message = "You must provide a disk name for the ova disk."
  }
}
variable "controlplane_nodes" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.controlplane_nodes != 1 || var.controlplane_nodes != 3
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
  default     = 2048
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
variable "node_extra_disk" {
  description = "Extra disk information"
  type = list(object({
    size = number
    mountpoint = string
  }))
  default = []
}
variable "add_extra_node_disk" {
  description = "Whether or not to add an additional disk."
  type = bool
  default = false
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

  validation {
    condition = var.ip_netmask != ""
    error_message = "You must provide an ip_netmask."
  }
}
variable "controlplane_ip_address_start" {
  description = "Don't overlap with worker_ip_address_start! The first control plane address IE: 100"
  type        = string
  default     = ""

  validation {
    condition = var.controlplane_ip_address_start != ""
    error_message = "You must provide a starting IP address for the controlplane nodes."
  }
}
variable "worker_ip_address_start" {
  description = "Don't overlap with controlplane_ip_address_start! The first worker address IE: 150"
  type        = string
  default     = ""

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

variable "talos_config_path" {
  description = <<EOT
      The full or relative path to the talos config file
      Full path: /home/user/talosconfig
      Relative path: ./config/talosconfig or ./talosconfig
    EOT
    type      = string
    default   = "./"

    validation {
      condition   = var.talos_config_path != ""
      error_message = "Talos config file path must be provided."
    }
}
variable "talos_crt" {
  description = "talos ca cert"
  type = string
  default = ""

  validation {
    condition = var.talos_crt != ""
    error_message = "Talos crt must be provided."
  }
}
variable "talos_key" {
  description = "talos ca key"
  type = string
  default = ""

  validation {
    condition = var.talos_key != ""
    error_message = "Talos key must be provided."
  }
}
variable "talos_token" {
  description = "Token used to join a system to the cluster"
  type = string
  default = ""

  validation {
    condition = var.talos_token != ""
    error_message = "Talos token must be provided."
  }
}
variable "kube_enc_key" {
  description = "The key used for the encryption of secret data at rest"
  type = string
  default = ""

  validation {
    condition = var.kube_enc_key != ""
    error_message = "Thekube_enc_key must be provided."
  }
}
variable "kube_token" {
  description = "The [bootstrap token](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/) used to join the cluster."
  type = string
  default = ""

  validation {
    condition = var.kube_token != ""
    error_message = "Kube token must be provided."
  }
}
variable "kube_crt" {
  description = "The base64 encoded root certificate authority cert used by Kubernetes."
  type = string
  default = ""

  validation {
    condition = var.kube_crt != ""
    error_message = "Kube crt must be provided."
  }
}
variable "kube_key" {
  description = "The base64 encoded root certificate authority key used by Kubernetes."
  type = string
  default = ""

  validation {
    condition = var.kube_key != ""
    error_message = "Kube key must be provided."
  }
}
variable "etcd_crt" {
  description = "The `ca` is the root certificate authority of the PKI."
  type = string
  default = ""

  validation {
    condition = var.etcd_crt != ""
    error_message = "ETCD crt must be provided."
  }
}
variable "etcd_key" {
  description = "The `ca` is the root certificate authority of the PKI."
  type = string
  default = ""

  validation {
    condition = var.etcd_key != ""
    error_message = "ETCD key must be provided."
  }
}
variable "admin_crt" {
  description = "the admin crt for conecting to k8"
  type = string
  default = ""

  validation {
    condition = var.admin_crt != ""
    error_message = "Talos crt must be provided."
  }
}
variable "admin_key" {
  description = "the admin key for connecting to k8"
  type = string
  default = ""

  validation {
    condition = var.admin_key != ""
    error_message = "Admin key must be provided."
  }
}
variable "allow_master_scheduling" {
  description = "Allows running workload on master nodes."
  type        = string
  default     = "false"
}

# Kube Cluster settings
variable "custom_cni" {
  description = "Customize CNI settings?"
  type        = bool
  default     = false
}
variable "cni_urls" {
  description = "URLs for kube CNI settings"
  type        = list(string)
  default     = []
}