# JupyterHub-GPU

This code deploys a JupyterHub with GPU support using z2jh Helm Chart. Ingress Controler, Hub and Proxy are running on master node. User pod are running on the worker nodes.
Nvidia stack is deployed using gpu-operator.
