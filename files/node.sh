#!/bin/bash
set -eu

chmod u+x /var/tmp/kubeadm_join_command.out
result=$(/var/tmp/kubeadm_join_command.out)

echo ${result}