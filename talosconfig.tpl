context: ${tf_cluster_name}
contexts:
  ${tf_cluster_name}:
    endpoints:
      - ${tf_endpoints}
    nodes:
      - ${tf_endpoints}
    ca: ${tf_talos_ca_crt}
    crt: ${tf_talos_admin_crt}
    key: ${tf_talos_admin_key}
