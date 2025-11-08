#! /bin/bash

kubectl create namespace vault;

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp 

helm install -n vault --set='server.dev.enabled=true' vault hashicorp/vault
kubectl get pod -n vault
