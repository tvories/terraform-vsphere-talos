# Talos on vSphere
[![GitHub](https://img.shields.io/github/license/tvories/terraform-vsphere-talos?style=flat)](https://github.com/tvories/terraform-vsphere-talos/blob/main/LICENSE)

The **terraform-vsphere-talos** module that can be used to build a [Talos](https://www.talos.dev/docs/v0.8/introduction/what-is-talos/#why-talos) based, fully compliant, [Kubernetes](https://kubernetes.io) cluster, using VMware vSphere and terraform.  Providing a (relatively) few variables will automatically spin up talos infrastructure on your vsphere environment.

This module has been heavily inspired by @masoudbahar https://github.com/masoudbahar/terraform-virtualbox-talos.

## Requirements

* Terraform > 0.13.x
* An existing vSphere environment with enough resources
* [talosctl](https://www.talos.dev/docs/v0.8/introduction/quickstart/#talosctl) commandline tool to generate the necessary certificates (eventually terraform will be able to handle this)
  * You can also provide your own certificate values instead of letting the script generate them

## Usage

Check out the [examples](https://github.com/tvories/terraform-vsphere-talos/tree/master/examples) directory for full configurations.

### Required for your Module

The [`terraform_vsphere_provider`](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs) needs to be declared in your project.  The bare minimum you must provide:

```terraform
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
```

The required module variables:
(Please read the [terraform registry documentation](https://registry.terraform.io/modules/tvories/talos/vsphere/latest?tab=inputs) for the full list of available inputs)

| Variable | Type     | Description |
| ------------ | ------------ | ------------ |
| `controlplane_nodes` | number | The number of control plane nodes (between 1 and 3) you want to have in your cluster |
|`worker_nodes`| number | The number of woker nodes you want in your cluster |
|`vsphere_datacenter` | string | The name of the datacenter in vSphere you want the cluster to be deployed to |
|`vsphere_resource_pool` | string | The name of the resource pool you want the cluster to be deployed to |
|`vsphere_datastore` | string | The name of the datastore you want the cluster to be deployed to |
|`vsphere_host` | string | The name of the host you want to cluster to be deployed to (this won't be required in the future if you specify a resource pool) |
|`vsphere_cluster` | string | The cluster the talos cluster will be deployed to |
|`vsphere_network`| string | The network you want to connect the talos cluster VMs to|
|`talos_cluster_endpoint`| string | The load balancer IP or DNS name of the cluster endpoints |
|`ip_gateway` | string | The gateway address for the node network |
|`ip_netmask` | string | The CIDR notation for the node network (this will be improved in a future release) |
|`dns_domain` | string | The node (not kubernetes cluster) dns domain |
|`ip_address_base` | string | The first 3 octets of your node network IE: `192.168.80`.  This will be improved in a future release |
|`controlplane_ip_address_start` | string | The final octet of the IP address for the first controlplane server IP IE: `20`  The way this is being done is dumb.  This will be fixed in a future release |
|`worker_ip_address_start` | string| The final octet of the IP address for the first worker server IP IE: `120`.  Will be fixed in a future release |

Talos expects base64 encoded certificates and tokens in order to bootstrap the cluster.  This module will eventually be able to generate these values without using `talosctl`, but for now, these values needed to be provided to the module.  [This script](https://github.com/tvories/terraform-vsphere-talos/blob/master/scripts/talos_certificates.sh) will generate the required certificates and output a terraform compatible file with the required fields.

Paste the generated values in the module or provide your own values.

```
talos_crt
talos_key
kube_crt
kube_key
etcd_crt
etcd_key
admin_crt
admin_key
talos_token
kube_token
kube_enc_key
```


## Configuration Values
See the [terraform-vsphere-talos](https://registry.terraform.io/modules/tvories/talos/vsphere/latest?tab=inputs) inputs page for the full list of available inputs.

## Features

## Limitations

## Compatability

## To Do
- [ ] Support multiple disks
- [ ] Optionally output talos yaml configurations
- [ ] Figure out way to add all controlplane endpoints to talosconfig.tpl
- [ ] Handle the IP address asignment better.  Choose a base block and then allow all nodes to pick from the pool
- [ ] remove the dependency on a vsphere host and allow for cluster selection
- [ ] add support to deploy from local ovf instead of url
- [ ] Support different kubernetes versions.  Update variables.
- [ ] Add ability to specify additional manifests
- [ ] Add ability to specify timeserver
- [ ] Add ability to specify your own init/controlplane/join yaml configuration files
- [ ] Move all key generation to terraform (waiting on https://github.com/hashicorp/terraform-provider-tls/pull/85)
- [ ] Support the ability to specify kubernetes cluster network customization
- [ ] Support the ability to deploy the cluster to different datastores