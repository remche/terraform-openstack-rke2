#cloud-config
write_files:
- path: /usr/local/bin/wait-for-node-ready.sh
  permissions: "0755"
  owner: root:root
  content: |
    #!/bin/sh
    until (curl -sL http://localhost:10248/healthz) && [ $(curl -sL http://localhost:10248/healthz) = "ok" ];
      do sleep 10 && echo "Wait for $(hostname) kubelet to be ready"; done;
- path: /usr/local/bin/install-or-upgrade-rke2.sh
  permissions: "0755"
  owner: root:root
  content: |
    #!/bin/sh
    # Install jq if not available
    JQ_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    JQ_BIN=/usr/local/bin/jq
    which jq 2>&1 > /dev/null || { sudo curl -sfL $JQ_URL -o $JQ_BIN && sudo chmod +x $JQ_BIN ; }

    # Fetch target and actual version if already installed
    export INSTALL_RKE2_VERSION=$(curl -s http://169.254.169.254/openstack/2012-08-10/meta_data.json|jq -r '.meta.rke2_version')
    which rke2 >/dev/null 2>&1 && RKE2_VERSION=$(rke2 --version|head -1|cut -f 3 -d " ")

    # Install or upgrade
    if ([ -z "$RKE2_VERSION" ]) || ([ -n "$INSTALL_RKE2_VERSION" ] && [ "$INSTALL_RKE2_VERSION" != "$RKE2_VERSION" ]); then
      RKE2_ROLE=$(curl -s http://169.254.169.254/openstack/2012-08-10/meta_data.json|jq -r '.meta.rke2_role')
      RKE2_SERVICE="rke2-$RKE2_ROLE.service"
      echo "Will install RKE2 $INSTALL_RKE2_VERSION with $RKE2_ROLE role"
      curl -sfL https://get.rke2.io | sh -
    fi
%{ if bootstrap_server == "" ~}
  %{~ for f in manifests_files ~}
- path: /var/lib/rancher/rke2/server/manifests/${f[0]}.yaml
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${f[1]}
  %{~ endfor ~}
  %{~ for k, v in manifests_gzb64 ~}
- path: /var/lib/rancher/rke2/server/manifests/${k}.yaml
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${v}
  %{~ endfor ~}
%{~ endif ~}
%{~ if registries_conf != "" ~}
- path: /etc/rancher/rke2/registries.yaml
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${registries_conf}
%{ endif ~}
%{~ if containerd_conf != "" ~}
- path: /var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl
  permissions: "0600"
  owner: root:root
  encoding: b64
  content: ${containerd_conf}
%{ endif ~}
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    token: "${rke2_token}"
    %{~ if bootstrap_server != "" ~}
    server: https://${bootstrap_server}:9345
    %{~ endif ~}
    %{~ if is_server ~}

    write-kubeconfig-mode: "0640"
    tls-san:
      ${indent(6, yamlencode(concat(san, additional_san)))}
    kube-apiserver-arg: "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    %{~ endif ~}
    ${indent(4,rke2_conf)}
%{ if is_server ~}
  %{~ for f in additional_config_files ~}
- path: /etc/rancher/rke2/${f[0]}
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${f[1]}
  %{~ endfor ~}
  %{~ for k, v in manifests_gzb64 ~}
- path: /etc/rancher/rke2/${k}
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${v}
  %{~ endfor ~}
%{ endif ~}
%{ if proxy_url != null ~}
- path: /etc/environment
  append: true
  content: |
    # BEGIN TERRAFORM MANAGED BLOCK
    http_proxy=${proxy_url}
    https_proxy=${proxy_url}
    ftp_proxy=${proxy_url}
    no_proxy=%{ for s in no_proxy ~}${s},%{ endfor }
    # END TERRAFORM MANAGED BLOCK
- path: /etc/default/rke2-server
  append: true
  content: |
    # BEGIN TERRAFORM MANAGED BLOCK
    HTTP_PROXY=${proxy_url}
    HTTPS_PROXY=${proxy_url}
    NO_PROXY=%{ for s in no_proxy ~}${s},%{ endfor }
    # END TERRAFORM MANAGED BLOCK
- path: /etc/default/rke2-agent
  append: true
  content: |
    # BEGIN TERRAFORM MANAGED BLOCK
    HTTP_PROXY=${proxy_url}
    HTTPS_PROXY=${proxy_url}
    NO_PROXY=%{ for s in no_proxy ~}${s},%{ endfor }
    # END TERRAFORM MANAGED BLOCK
%{ endif ~}
runcmd:
%{ if proxy_url != null ~}
  - export http_proxy=${proxy_url}
  - export https_proxy=${proxy_url}
  - export no_proxy=%{ for s in no_proxy ~}${s},%{ endfor }${bootstrap_server}
%{ endif ~}
  - /usr/local/bin/install-or-upgrade-rke2.sh
  %{~ if is_server ~}
    %{~ if bootstrap_server != "" ~}
  - [ sh,  -c, 'until (curl -ksS -m 5 -o /dev/null https://${bootstrap_server}:6443); do echo Wait for master node && sleep 10; done;']
    %{~ endif ~}
  - systemctl enable rke2-server.service
  - systemctl start rke2-server.service
  - [ sh, -c, 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do echo Waiting for rke2 to start && sleep 10; done;' ]
  - [ sh, -c, 'until [ -x /var/lib/rancher/rke2/bin/kubectl ]; do echo Waiting for kubectl bin && sleep 10; done;' ]
  - cp /etc/rancher/rke2/rke2.yaml /etc/rancher/rke2/rke2-remote.yaml
  - sudo chgrp ${system_user} /etc/rancher/rke2/rke2-remote.yaml
  - KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config set-cluster default --server https://${public_address}:6443
  - KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config rename-context default ${cluster_name}
  %{~ else ~}
  - systemctl enable rke2-agent.service
  - systemctl start rke2-agent.service
  %{~ endif ~}
