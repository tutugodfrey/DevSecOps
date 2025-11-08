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

Deploy

```bash
kubectl create deployment dso-demo --image=index.docker.io/tutug/dso-demo --replicas=1 --port=8080 --dry-run=client -o yaml | tee deploy/dso-demo-deploy.yaml

kubectl create service nodeport dso-demo --tcp=8080 --node-port=30080 --dry-run=client -o yaml | tee deploy/dso-demo-svc.yaml

git add deploy/dso-demo-deploy.yaml deploy/dso-demo-svc.yaml 
git commit -am "add k8s manifests to deploy dso-demo app"
git push origin main
```


[ZAP Docker Images in GitHub Container Registry](https://www.zaproxy.org/blog/2023-06-13-ghcr-docker-images/)
[sast-scan](https://github.com/ShiftLeftSecurity/sast-scan)
[SonarQube](https://www.sonarsource.com/open-source-editions/sonarqube-community-edition/)
[spring-boot](https://github.com/spring-projects/spring-boot)
[Dependency-check](https://jeremylong.github.io/DependencyCheck/dependency-check-maven/index.html)
[OWASP Dependency-Track](https://owasp.org/www-project-dependency-track/)
[dockle](https://github.com/goodwithtech/dockle)


### Install Inspec

```bash
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec

inspec exec linux-baseline

Created ssh key for devsecops-course

ssh-keygen -t ecdsa -m PEM  # provide devsecops-course at the prompt 

cat ~/.ssh/devsecops-course # Used the private to create credential in Jenkins
cat ~/.ssh/devsecops-course.pub # Add the public key to authorized_keys in the ubuntu linux host

git clone https://github.com/tutugodfrey/secops.git
cd secops/ansible/
ansible -i environments/prod all -m ping
ansible-galaxy collection install devsec.hardening
ansible-playbook compliance.yaml
```


```bash
git clone https://github.com/aquasecurity/kube-bench.git
cd kube-bench/
kubectl apply -f job.yaml

docker run -it --rm --network host aquasec/kube-hunter
git clone https://github.com/aquasecurity/kube-hunter.git
cd kube-hunter/
kubectl apply -f job.yaml
kubectl logs -f kube-hunter-lctfd 


docker run -i kubesec/kubesec scan /dev/stdin < dso-demo-deploy.yaml
kubectl run docker-tool --image=rmkanda/docker-tools:latest --command --  sh -c "sleep 500"

```

Working with vault

```bash
vault
vault status
vault secrets list
vault kv put secret/dso-demo/database username=devops password=mysupersecret

vault secrets list

vault kv list secret
vault kv list secret/dso-demo
vault kv get secret/dso-demo/database

vault policy

vault policy write dso-demo - <<EOF
path "secret/data/dso-demo/database" {
  capabilities = ["read"]
}
EOF

vault policy list
vault policy read dso-demo

vault auth
vault auth list
vault auth enable kubernetes
vault auth list

# Connect kubernetes with vault
env | grep -i kube

ls /var/run/secrets/kubernetes.io/serviceaccount/

# Configure the kubernetes auth backend
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
issuer="https://kubernetes.default.svc.cluster.local"

# Success! Data written to: auth/kubernetes/config

vault write auth/kubernetes/role/dso-demo bound_service_account_names=dso-demo bound_service_account_namespaces=default policies=dso-demo ttl=30h

vault write auth/kubernetes/role/dso-demo bound_service_account_names=dso-demo bound_service_account_namespaces=dev policies=dso-demo ttl=30h
# Success! Data written to: auth/kubernetes/role/dso-demo


vault kv get secret/dso-demo/database
vault kv put secret/dso-demo/database user=devops password NewSuperDuperSecret

```

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: dso-demo
  name: dso-demo
  annotations:
    seccomp.security.alpha.kubernetes.io/pod: "runtime/default"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dso-demo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: dso-demo
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'dso-demo'
        vault.hashicorp.com/agent-inject-secret-database: 'secret/dso-demo/database'
        vault.hashicorp.com/agent-inject-template-database: |
          {{- with secret "secret/dso-demo/database" -}} mysql -u {{ .Data.data.username }} -p {{ .Data.data.password }} -h database:3306 mydb  {{- end -}}
    spec:
      serviceAccountName: dso-demo
      #automountServiceAccountToken: false
      containers:
      - image: index.docker.io/tutug/dso-demo
        name: dso-demo
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: "50m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
        securityContext:
          capabilities:
            drop:
            - ALL
          privileged: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 11000
          readOnlyRootFilesystem: true
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}


kind: ServiceAccount
metadata:
  name: dso-demo

```

```bash
kubectl -n dev exec -it dso-demo-584bf7484-pd4rr  -- sh
cat /vault/secrets/database
```

## Install falco

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm search repo falcosecurity
helm install falco falcosecurity/falco -n falco --create-namespace --set falcosidekick.enabled=true --set tty=true --set driver.kind=modern-bpf

kubectl -n falco get pods -o wide

# Run a pod to test how falco detect events
kubectl run test -it --image=ubuntu

kubectl -n falco logs -f falco-7499r


kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{ .data.password }" | base64 -d; echo ### nFPNoWGXManD20Wi
kubectl get nodes   # Select a node IP
kubectl get svc -n argocd    # get nodePort
argocd login 172.30.2.2:30164 --grpc-web --plaintext

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm search repo falcosecurity
helm upgrade --install falco falcosecurity/falco -n falco --create-namespace --set falcosidekick.enable=true --set tty=true --set driver.kind=modern-bpf
```