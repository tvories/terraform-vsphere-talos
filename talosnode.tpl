version: v1alpha1 # Indicates the schema used to decode the contents.
debug: false # Enable verbose logging to the console.
persist: true # Indicates whether to pull the machine config upon every boot.
# Provides machine specific configuration options.
machine:
    type: ${type} # Defines the role of the machine within the cluster.
    token: ${talos_join_token} # The `token` is used by a machine to join the PKI of the cluster.
%{ if type != "worker" ~}
    # The root certificate authority of the PKI.
    ca:
        crt: ${talos_ca_crt}
        key: ${talos_ca_key}
%{ endif ~}
    # Used to provide additional options to the kubelet.
    kubelet: {}
    # # The `image` field is an optional reference to an alternative kubelet image.
    # image: ghcr.io/talos-systems/kubelet:v1.20.1

    # # The `extraArgs` field is used to provide additional flags to the kubelet.
    # extraArgs:
    #     key: value

    # # The `extraMounts` field is used to add additional mounts to the kubelet container.
    # extraMounts:
    #     - destination: /var/lib/example
    #       type: bind
    #       source: /var/lib/example
    #       options:
    #         - rshared
    #         - rw

    # Provides machine specific network configuration options.
%{if customize_network ~}
    network:
      hostname: ${hostname}
      interfaces:
      - interface: eth0
        cidr: ${node_ip_address}${ip_netmask}
        routes:
        - network: 0.0.0.0/0
          gateway: ${ip_gateway}
        mtu: 1500

        dhcp: false

      nameservers:
%{for ns in nameservers ~}
      - ${ns}
%{endfor ~}
%{else ~}
    network: {}
%{endif ~}
    # # `interfaces` is used to define the network interface configuration.
    # interfaces:
    #     - interface: eth0 # The interface name.
    #       cidr: 192.168.2.0/24 # Assigns a static IP address to the interface.
    #       # A list of routes associated with the interface.
    #       routes:
    #         - network: 0.0.0.0/0 # The route's network.
    #           gateway: 192.168.2.1 # The route's gateway.
    #           metric: 1024 # The optional metric for the route.
    #       mtu: 1500 # The interface's MTU.
    #
    #       # # Bond specific options.
    #       # bond:
    #       #     # The interfaces that make up the bond.
    #       #     interfaces:
    #       #         - eth0
    #       #         - eth1
    #       #     mode: 802.3ad # A bond option.
    #       #     lacpRate: fast # A bond option.

    #       # # Indicates if DHCP should be used to configure the interface.
    #       # dhcp: true

    #       # # DHCP specific options.
    #       # dhcpOptions:
    #       #     routeMetric: 1024 # The priority of all routes received via DHCP.

    # # Used to statically set the nameservers for the machine.
    # nameservers:
    #     - 8.8.8.8
    #     - 1.1.1.1

    # # Allows for extra entries to be added to the `/etc/hosts` file
    # extraHostEntries:
    #     - ip: 192.168.1.100 # The IP of the host.
    #       # The host alias.
    #       aliases:
    #         - example
    #         - example.domain.tld

    # Used to provide instructions for installations.
    install:
        disk: /dev/sda # The disk used for installations.
        image: ghcr.io/talos-systems/installer:v0.8.3 # Allows for supplying the image used to perform the installation.
        bootloader: true # Indicates if a bootloader should be installed.
        wipe: false # Indicates if the installation disk should be wiped at installation time.

        # # Allows for supplying extra kernel args via the bootloader.
        # extraKernelArgs:
        #     - talos.platform=metal
        #     - reboot=k

    # # Extra certificate subject alternative names for the machine's certificate.

    # # Uncomment this to enable SANs.
    # certSANs:
    #     - 10.0.0.10
    #     - 172.16.0.10
    #     - 192.168.0.10

    # # Used to partition, format and mount additional disks.

    # # MachineDisks list example.
    # disks:
    #     - device: /dev/sdb # The name of the disk to use.
    #       # A list of partitions to create on the disk.
    #       partitions:
    #         - mountpoint: /var/mnt/extra # Where to mount the partition.
    #
    #           # # This size of partition: either bytes or human readable representation.

    #           # # Human readable representation.
    #           # size: 100 MB
    #           # # Precise value in bytes.
    #           # size: 1073741824

    # # Allows the addition of user specified files.

    # # MachineFiles usage example.
    # files:
    #     - content: '...' # The contents of the file.
    #       permissions: 0o666 # The file's permissions in octal.
    #       path: /tmp/file.txt # The path of the file.
    #       op: append # The operation to use

    # # The `env` field allows for the addition of environment variables.

    # # Environment variables definition examples.
    # env:
    #     GRPC_GO_LOG_SEVERITY_LEVEL: info
    #     GRPC_GO_LOG_VERBOSITY_LEVEL: "99"
    #     https_proxy: http://SERVER:PORT/
    # env:
    #     GRPC_GO_LOG_SEVERITY_LEVEL: error
    #     https_proxy: https://USERNAME:PASSWORD@SERVER:PORT/
    # env:
    #     https_proxy: http://DOMAIN\USERNAME:PASSWORD@SERVER:PORT/

    # # Used to configure the machine's time settings.

    # # Example configuration for cloudflare ntp server.
    # time:
    #     disabled: false # Indicates if the time service is disabled for the machine.
    #     # Specifies time (NTP) servers to use for setting the system time.
    #     servers:
    #         - time.cloudflare.com

    # # Used to configure the machine's sysctls.

    # # MachineSysctls usage example.
    # sysctls:
    #     kernel.domainname: talos.dev
    #     net.ipv4.ip_forward: "0"

    # # Used to configure the machine's container image registry mirrors.
    # registries:
    #     # Specifies mirror configuration for each registry.
    #     mirrors:
    #         ghcr.io:
    #             # List of endpoints (URLs) for registry mirrors to use.
    #             endpoints:
    #                 - https://registry.insecure
    #                 - https://ghcr.io/v2/
    #     # Specifies TLS & auth configuration for HTTPS image registries.
    #     config:
    #         registry.insecure:
    #             # The TLS configuration for the registry.
    #             tls:
    #                 insecureSkipVerify: true # Skip TLS server certificate verification (not recommended).
    #
    #                 # # Enable mutual TLS authentication with the registry.
    #                 # clientIdentity:
    #                 #     crt: TFMwdExTMUNSVWRKVGlCRFJWSlVTVVpKUTBGVVJTMHRMUzB0Q2sxSlNVSklla05DTUhGLi4u
    #                 #     key: TFMwdExTMUNSVWRKVGlCRlJESTFOVEU1SUZCU1NWWkJWRVVnUzBWWkxTMHRMUzBLVFVNLi4u
    #
    #             # # The auth configuration for this registry.
    #             # auth:
    #             #     username: username # Optional registry authentication.
    #             #     password: password # Optional registry authentication.
# Provides cluster specific configuration options.
cluster:
    # Provides control plane specific configuration options.
    controlPlane:
        endpoint: https://${cluster_endpoint}:6443 # Endpoint is the canonical controlplane endpoint, which can be an IP address or a DNS hostname.
%{ if type != "worker" ~}
    clusterName: ${kube_cluster_name} # Configures the cluster's name.
%{ endif ~}
    # Provides cluster specific network configuration options.
    network:
        dnsDomain: ${kube_dns_domain} # The domain used by Kubernetes DNS.
        # The pod subnet CIDR.
        podSubnets:
            - 10.244.0.0/16
        # The service subnet CIDR.
        serviceSubnets:
            - 10.96.0.0/12

        # # The CNI used.
        # cni:
        #     name: custom # Name of CNI to use.
        #     # URLs containing manifests to apply for the CNI.
        #     urls:
        #         - https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml
    token: ${kube_token} # The [bootstrap token](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/) used to join the cluster.
%{ if type != "worker" ~}
    aescbcEncryptionSecret: ${kube_enc_key} # The key used for the [encryption of secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).
%{ endif ~}
    # The base64 encoded root certificate authority used by Kubernetes.
    ca:
      crt: ${kube_ca_crt}
%{ if type != "worker" ~}
      key: ${kube_ca_key}
%{ else ~}
      key: ""
%{ endif ~}
%{ if type != "worker" ~}
    # API server specific configuration options.
    apiServer:
        # Extra certificate subject alternative names for the API server's certificate.
      certSANs:
      - ${cluster_endpoint}

        # # The container image used in the API server manifest.
        # image: k8s.gcr.io/kube-apiserver-amd64:v1.20.1
    # Controller manager server specific configuration options.
    controllerManager: {}
    # # The container image used in the controller manager manifest.
    # image: k8s.gcr.io/kube-controller-manager-amd64:v1.20.1

    # Kube-proxy server-specific configuration options
    proxy: {}
    # # The container image used in the kube-proxy manifest.
    # image: k8s.gcr.io/kube-proxy-amd64:v1.20.1

    # Scheduler server specific configuration options.
    scheduler: {}
    # # The container image used in the scheduler manifest.
    # image: k8s.gcr.io/kube-scheduler-amd64:v1.20.1

    # Etcd specific configuration options.
    etcd:
      # The `ca` is the root certificate authority of the PKI.
      ca:
        crt: ${etcd_ca_crt}
        key: ${etcd_ca_key}

        # # The container image used to create the etcd service.
        # image: gcr.io/etcd-development/etcd:v3.4.14
%{ endif }
    # # Pod Checkpointer specific configuration options.
    # podCheckpointer:
    #     image: '...' # The `image` field is an override to the default pod-checkpointer image.

    # # Core DNS specific configuration options.
    # coreDNS:
    #     image: k8s.gcr.io/coredns:1.7.0 # The `image` field is an override to the default coredns image.

    # # A list of urls that point to additional manifests.
    # extraManifests:
    #     - https://www.example.com/manifest1.yaml
    #     - https://www.example.com/manifest2.yaml

    # # A map of key value pairs that will be added while fetching the ExtraManifests.
    # extraManifestHeaders:
    #     Token: "1234567"
    #     X-ExtraInfo: info

    # # Settings for admin kubeconfig generation.
    # adminKubeconfig:
    #     certLifetime: 1h0m0s # Admin kubeconfig certificate lifetime (default is 1 year).
