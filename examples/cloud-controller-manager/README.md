# Cloud Controller Manager

This example implements deploying the **Cloud Controlller Manager** as well as the **cinder-csi-plugin**. 

In Kubernetes the Cloud Controller Manager is responsible for managing Load Balancers, as well as configuring some other options such as MetaData

https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#load-balancer

This example disables the default cloud-controller-manager-rke2, and that is required as it will otherwise conflict.

## Creating a Loadbalancer

If properly configured you can create a LoadBalancer like so:
```
apiVersion: v1
kind: Service
metadata:
  name: tools
  namespace: default
spec:
  type: LoadBalancer
  selector:
    app: tools
  ports:
    - port: 8000
      targetPort: 8000
      name: http
      protocol: TCP
```

## Debugging
You can tail the logs of the cloud controller manager 

```
kubectl logs -n kube-system -L app=openstack-cloud-controller-manager
```

