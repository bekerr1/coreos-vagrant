#!/bin/bash

# etcd coreos machines need to have etcd-member service and flannel service running
# to be affective in kub cluster

etcd=systemctl is-active --quite etcd-member && echo Etcd-member service is running
flannel=systemctl is-active --quite flanneld && echo Flannel service is running

if [ $etcd && $flannel ]; then
    echo 'All (required) systems go'
else
    echo "Some nessesary systems didnt start"
fi

echo "End system checks"
