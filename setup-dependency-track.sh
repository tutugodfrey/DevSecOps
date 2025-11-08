#! /bin/bash

# helm repo add evryfs-oss https://evryfs.github.io/helm-charts/

# https://artifacthub.io/packages/helm/dependencytrack/dependency-track
# https://github.com/DependencyTrack/helm-charts/blob/main/charts/dependency-track/values.yaml
helm repo add dependency-track https://dependencytrack.github.io/helm-charts
helm repo update 
kubectl create namespace dependency-track

# https://github.com/evryfs/helm-charts/tree/master
# helm upgrade --install dependency-track evryfs-oss/dependency-track --namespace dependency-track --values deptrack.values.yaml

helm upgrade --install dependency-track dependency-track/dependency-track --namespace dependency-track --values deptrack.values.yaml

helm list -n dependency-track

kubectl get all -n dependency-track
