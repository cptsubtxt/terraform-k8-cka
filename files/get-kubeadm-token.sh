#!/bin/bash
set -eu
SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}
SSH_USERNAME=${SSH_USERNAME:-}
SSH_HOST=${SSH_HOST:-}

OUTDIR=${OUTDIR:-}

mkdir -p "${OUTDIR}"

# ssh -tt -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
#     -i "${SSH_PRIVATE_KEY}" \
#     "${SSH_USERNAME}@${SSH_HOST} kubeadm token create --print-join-command > /var/tmp/kubeadm_join_command.out"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST}:/var/tmp/kubeadm_join_command.out" \
    "${OUTDIR}"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "${SSH_PRIVATE_KEY}" \
    "${SSH_USERNAME}@${SSH_HOST}:/etc/kubernetes/admin.conf" \
    "${OUTDIR}"