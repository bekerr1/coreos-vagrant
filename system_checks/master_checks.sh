#!/bin/bash

# kube master needs to have flannel, kubelet, and docker services running
# to function correctly

flannel=systemctl is-active --quite flanneld && echo Flannel service is running
kubelet=systemctl is-active --quite kubelet && echo Kubelet service is running
docker=systemctl is-active --quite docker && echo Docker service is running

if [ $flannel && $kubelet && $docker ]; then
    echo 'All (required) systems go!'
else
    echo "Some nessesary systems didnt start"
fi

echo "End systems check"
