#cloud-config
write_files:
%{ if bootstrap_server == "" ~}
  %{~ for index, f in manifests ~}
- path: /var/lib/rancher/rke2/server/manifests/addon-${index}.yaml
  permissions: "0600"
  owner: root:root
  encoding: gz+b64
  content: ${f}
  %{~ endfor ~}
%{~ endif ~}
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    token: ${rke2_cluster_secret}
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
runcmd:
  %{~ if is_server ~}
    %{~ if bootstrap_server != "" ~}
  - [ sh,  -c, 'until (nc -z ${bootstrap_server} 6443); do echo Wait for master node && sleep 10; done;']
    %{~ endif ~}
  - systemctl enable rke2-server.service
  - systemctl start rke2-server.service
  - [ sh, -c, 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do echo Waiting for rke2 to start && sleep 10; done;' ]
  - sudo chgrp sudo /etc/rancher/rke2/rke2.yaml
  - [ sh, -c, 'until [ -x /var/lib/rancher/rke2/bin/kubectl ]; do echo Waiting for kubectl bin && sleep 10; done;' ]
  - KUBECONFIG=/etc/rancher/rke2/rke2.yaml /var/lib/rancher/rke2/bin/kubectl config rename-context default rke2
  - KUBECONFIG=/etc/rancher/rke2/rke2.yaml /var/lib/rancher/rke2/bin/kubectl config set-cluster default --server https://${public_address}:6443
  %{~ else ~}
  - systemctl enable rke2-agent.service
  - systemctl start rke2-agent.service
  %{~ endif ~}
