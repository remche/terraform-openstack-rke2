#cloud-config
write_files:
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    %{ if bootstrap_server != "" }
    server: https://${bootstrap_server}:9345
    %{ endif }
    token: ${rke2_cluster_secret}
    %{ if is_master && bootstrap_server == ""}
    write-kubeconfig-mode: "0640"
    tls-san:
      - ${master_public_address}
    kube-apiserver-arg: "kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
    %{ endif }
runcmd:
  %{ if is_master }
  - sudo systemctl enable rke2-server.service
  - sudo systemctl start rke2-server.service
  - [ sh, -c, 'while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do echo Waiting for rke2 to start && sleep 10; done; sudo chgrp sudo /etc/rancher/rke2/rke2.yaml' ]
  - sudo chgrp sudo /etc/rancher/rke2/rke2.yaml
  - KUBECONFIG=/etc/rancher/rke2/rke2.yaml /var/lib/rancher/rke2/bin/kubectl config rename-context default rke2
  - KUBECONFIG=/etc/rancher/rke2/rke2.yaml /var/lib/rancher/rke2/bin/kubectl config set-cluster default --server https://${master_public_address}:6443
  %{ else }
  - sudo systemctl enable rke2-agent.service
  - sudo systemctl start rke2-agent.service
  %{ endif }
