# DevSecOps

### Install Jenkins on Kubernetes

Use the setup script `setup-jenkins.sh` to deploy Jenkins on kubernetes cluster. Execute the following command.

```bash
./setup-jenkins.sh
```

Check the deployment

```bash
helm list -n ci
kubectl get svc -n ci
```

Access the service on NodePort.

http://external_ip:NodePort

Get Jenkins initial admin Password

```bash
printf $(kubectl get secret --namespace ci jenkins -o jsonpath="{ .data.jenkins-admin-passowrd}" | base64 -decode); echo
```

