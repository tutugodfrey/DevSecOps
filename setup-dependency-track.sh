#! /bin/bash

helm repo add evryfs-oss https://evryfs.github.io/helm-charts/
helm repo update 
kubectl create namespace dependency-track

helm upgrade --install dependency-track evryfs-oss/dependency-track --namespace dependency-track --values deptrack.values.yaml

helm list -n dependency-track

kubectl get all -n dependency-track
