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
printf $(kubectl get secret --namespace ci jenkins -ojsonpath="{.data.jenkins-admin-password}" | base64 --decode); echo
```

### Create docker registry secret

```bash
kubectl create secret -n ci docker-registry regcred --docker-server=https://index.docker.io/v1/  --docker-username=xxxxxx --docker-password=yyyyyy --docker-email=xyz@abc.org

kubectl create secret -n ci docker-registry regcred --docker-server=https://index.docker.io/v1/  --docker-username=tutug --docker-password=replace-with-docker-personal-access-token --docker-email=godfrey_tutu@yahoo.com
```
