### Nvidia GPU Operator 

This installs the Nvidia GPU Operator. It adds custom containerd runtime settings. Test is it working with this - 

```
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vectoradd
spec:
  restartPolicy: OnFailure
  containers:
  - name: cuda-vectoradd
    image: "nvidia/samples:vectoradd-cuda11.2.1"
    resources:
      limits:
         nvidia.com/gpu: 1
EOF
```
[https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#running-sample-gpu-applications](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#running-sample-gpu-applications)
