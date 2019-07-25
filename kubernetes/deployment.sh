#!/bin/bash

docker build -t app .
kubectl apply -f ./config/namespace.yaml
kubectl apply -f ./config/deployment.yaml
kubectl apply -f ./config/autoscaler.yaml
kubectl apply -f ./config/service.yaml
kubectl apply -f ./config/ingress.yaml
kubectl config set-context minikube --namespace app1
echo "Endereço: http://`minikube ip`/app"