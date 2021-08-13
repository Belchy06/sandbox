#!/usr/bin/env bash

# stops the execution if a command or pipeline has an error
set -eu

docker build -t $TINKERBELL_HOST_IP/ubuntu:base deploy/workflow-images/base/ && docker push $TINKERBELL_HOST_IP/ubuntu:base

docker build -t $TINKERBELL_HOST_IP/disk-wipe:v1.0.0 --build-arg REGISTRY=$TINKERBELL_HOST_IP deploy/workflow-images/disk-wipe/ && docker push $TINKERBELL_HOST_IP/disk-wipe:v1.0.0

docker pull quay.io/tinkerbell-actions/writefile:v1.0.0 && docker tag quay.io/tinkerbell-actions/writefile:v1.0.0 $TINKERBELL_HOST_IP/writefile:v1.0.0 && docker push $TINKERBELL_HOST_IP/writefile:v1.0.0

docker pull quay.io/tinkerbell-actions/image2disk:v1.0.0 && docker tag quay.io/tinkerbell-actions/image2disk:v1.0.0 $TINKERBELL_HOST_IP/image2disk:v1.0.0 && docker push $TINKERBELL_HOST_IP/image2disk:v1.0.0

docker build -t $TINKERBELL_HOST_IP/reboot:v1.0.0 deploy/workflow-images/reboot/ && docker push $TINKERBELL_HOST_IP/reboot:v1.0.0