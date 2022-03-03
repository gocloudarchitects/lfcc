#!/bin/bash
mkdir -p converted

tfk8s -f manifests/01-db-service.yml -o converted/01-db-service.yml
tfk8s -f manifests/02-db-pvc.yml -o converted/02-db-pvc.yml
tfk8s -f manifests/03-db-deployment.yml -o converted/03-db-deployment.yml
tfk8s -f manifests/04-frontend-service.yml -o converted/04-frontend-service.yml
tfk8s -f manifests/05-frontend-pvc.yml -o converted/05-frontend-pvc.yml
tfk8s -f manifests/06-frontend-deployment.yml -o converted/06-frontend-deployment.yml
tfk8s -f manifests/secret.yml -o converted/00-secret.yml
