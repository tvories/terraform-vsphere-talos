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

## Configuration Values

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