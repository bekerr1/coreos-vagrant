#!/bin/bash

# so i can use alias commands
shopt -s expand_aliases
source $HOME/.alias

echo "Replacing expired discover url with new"
disc_token=\"
disc_token+=$(curl -s https://discovery.etcd.io/new\?size\=$1)
disc_token+=\"
sed -i -E "s|\"https://discovery.etcd.io/.*|$disc_token|g" cl-etcd.conf 
echo $disc_token

echo "Running config transpile commands"
ctv cl-etcd.conf config-etcd.ign
ctvf cl-master.conf config-master.ign ./pod_yamls
#
echo "Running Vagrant up"
vagrant up
