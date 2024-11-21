#! /bin/bash

helm repo add jenkins https://charts.jenkins.io
helm repo update
kubectl create namespace ci
helm upgrade --install jenkins jenkins/jenkins --namespace ci --values jenkins.values.yaml
