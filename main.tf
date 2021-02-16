# Populate the info for the individual nodes
locals {
    # Total number of nodes
    talos_nodes = length(var.worker_nodes) > 0 ? (var.controlplane_nodes + var.worker_nodes) : var.controlplane_nodes
    controlplane_nodes_config = [
        for cp in range(var.controlplane_nodes)
    ]
}