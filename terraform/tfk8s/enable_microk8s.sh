#!/bin/bash
sudo snap install microk8s --classic
microk8s enable dashboard dns istio registry storage
microk8s config > ~/.kube/config
