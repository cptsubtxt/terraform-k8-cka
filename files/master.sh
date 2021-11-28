#!/bin/bash
set -eu

DOCKER_VERSION=${DOCKER_VERSION:-}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-}
NETWORK_ID=${KUBERNETES_VERSION:-}
API_TOKEN=${KUBERNETES_VERSION:-}


kubeadm config images pull
kubeadm init \
  --pod-network-cidr=10.0.0.0/16 \
  --kubernetes-version=${KUBERNETES_VERSION} \
  --ignore-preflight-errors=NumCPU \
  --upload-certs \
  --apiserver-cert-extra-sans 10.0.0.1

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
stringData:
  token: "${API_TOKEN}"
  network: "${NETWORK_ID}"
---
apiVersion: v1
kind: Secret
metadata:
  name: hcloud-csi
  namespace: kube-system
stringData:
  token: "${API_TOKEN}"
EOF

# Following this doc
# https://github.com/hetznercloud/hcloud-cloud-controller-manager

# Install networking e.g. flannel
# kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

# Patch flannel 
# kubectl -n kube-system patch ds kube-flannel-ds --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# Install networking calico as this will be used for use of Network Policies

kubectl apply -f /root/calico.yaml

# Install Hetzner Cloud Controller Manager
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/hcloud-cloud-controller-manager/master/deploy/ccm-networks.yaml

kubeadm token create --print-join-command > /var/tmp/kubeadm_join_command.out