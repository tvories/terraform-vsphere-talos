context: ${tf_cluster_name}
contexts:
  ${tf_cluster_name}:
    endpoints:
%{for ip in tf_endpoints ~}
      - ${ip}
%{endfor ~}
    nodes:
      - ${tf_endpoints[0]}
    ca: ${tf_talos_ca_crt}
    crt: ${tf_talos_admin_crt}
    key: ${tf_talos_admin_key}
