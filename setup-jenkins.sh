#! /bin/bash

# https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/values.yaml
helm repo add jenkins https://charts.jenkins.io
helm repo update
kubectl create namespace ci
kubectl apply -f jenkins.yaml -n ci
helm upgrade --install jenkins jenkins/jenkins --namespace ci --values jenkins.values.yaml
