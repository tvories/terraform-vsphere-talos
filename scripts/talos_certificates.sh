#!/bin/bash
# This script is used for generation of various Talos cluster certificates
# The output is a terraform tfvars file

function check_deps {
  [[ -f $(which talosctl) ]] || { echo "talosctl command not detected in path, please install it";  exit 404; }
}

function gen_certs {

  # Generate Talos Machine CA certificate (Ed25519)
  talosctl gen ca --hours 87600 --organization talos

  # Generate Kubernetes CA certificate (RSA 4096)
  talosctl gen ca --rsa --hours 87600 --organization kubernetes

  # Generate the etcd CA certificate (RSA 4096)
  talosctl gen ca --rsa --hours 87600 --organization etcd

  # Generate the Talos admin certificate (Ed25519)
  talosctl gen key --name admin
  talosctl gen csr --ip "127.0.0.1" --key admin.key
  talosctl gen crt  --name admin --hours 87600 --ca talos --csr admin.csr
}

function random {
  # Only returns even numbered values
  # I am not clever enough right now to return odd random string
  num=$((${1} / 2))
  xxd -l ${num} -c ${num} -p < /dev/random
}

function gen_tokens {
  TALOS_TOKEN="$(random 6).$(random 16)"
  KUBE_TOKEN="$(random 6).$(random 16)"
  KUBE_ENC_KEY="$(head -c 32 /dev/urandom | base64)"
}

function get_b64_strings {
  # The current directory, because of gen_certs function, is CONF_DIR
	if (uname -a | grep 'Darwin' > /dev/null); then # Host is macOS
    TALOS_CRT=$(base64 -i talos.crt)
    TALOS_KEY=$(base64 -i talos.key)
    KUBE_CRT=$(base64 -i kubernetes.crt)
    KUBE_KEY=$(base64 -i kubernetes.key)
    ETCD_CRT=$(base64 -i etcd.crt)
    ETCD_KEY=$(base64 -i etcd.key)
    ADMIN_CRT=$(base64 -i admin.crt)
    ADMIN_KEY=$(base64 -i admin.key)
	else # Host is Linux, as other platforms are not tested to be evaluated here
    TALOS_CRT=$(base64 -w 0 talos.crt)
    TALOS_KEY=$(base64 -w 0 talos.key)
    KUBE_CRT=$(base64 -w 0 kubernetes.crt)
    KUBE_KEY=$(base64 -w 0 kubernetes.key)
    ETCD_CRT=$(base64 -w 0 etcd.crt)
    ETCD_KEY=$(base64 -w 0 etcd.key)
    ADMIN_CRT=$(base64 -w 0 admin.crt)
    ADMIN_KEY=$(base64 -w 0 admin.key)
  fi

  # Delete certificate files
  rm -f talos.crt talos.key \
  kubernetes.crt kubernetes.key \
  etcd.crt etcd.key \
  admin.crt admin.key \
  talos.sha256 etcd.sha256 admin.csr kubernetes.sha256
}

function write_tfvars {
  # Writes the values to a terraform tfvars file
  tee talos_crts.auto.tfvars > /dev/null <<EOF
  talos_crt = "${TALOS_CRT}"
  talos_key = "${TALOS_KEY}"
  kube_crt = "${KUBE_CRT}"
  kube_key = "${KUBE_KEY}"
  etcd_crt = "${ETCD_CRT}"
  etcd_key = "${ETCD_KEY}"
  admin_crt = "${ADMIN_CRT}"
  admin_key = "${ADMIN_KEY}"
  talos_token = "${TALOS_TOKEN}"
  kube_token = "${KUBE_TOKEN}"
  kube_enc_key = "${KUBE_ENC_KEY}"
EOF
}

check_deps &&
gen_certs &&
gen_tokens &&
get_b64_strings &&
write_tfvars
