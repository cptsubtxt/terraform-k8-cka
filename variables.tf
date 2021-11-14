variable "hcloud_token" {
  description = "Hetzner cloud auth token"
}

variable "cluster_name" {
  description = "Cluster name for resources"
  default     = "k8s"
}

variable "datacenter" {
  description = "Hetzner datacenter where resources resides, hel1-dc2 (Helsinki 1 DC 2) or fsn1-dc14 (Falkenstein 1 DC14)"
  default     = "fsn1-dc14"
}

variable "image" {
  description = "Node boot image"
  default     = "ubuntu-20.04"
}

variable "master_count" {
  description = "How many masternodes should be provisioned"
  default = "1"
}

variable "master_type" {
  description = "Master node type (size)"
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
}

variable "node_type" {
  description = "Node type (size)"
  default     = "cx21" # 2 vCPU, 4 GB RAM, 40 GB Disk space
}

variable "node_count" {
  description = "How many Nodes should be provisioned"
  default = "2"
}

variable "ssh_keys" {
  type        = list
  description = "List of public ssh_key ids"
}

variable "ssh_private_key" {
  description = "Private Key to access the machines"
  default     = "ssh-keys/id_rsa_hcloud"
}

variable "ssh_public_key" {
  description = "Public Key to access the machines"
  default     = "ssh-keys/id_rsa_hcloud.pub"
}

variable "kubernetes_version" {
  description = "Specify Kuernetes version"
  default = "1.22.3"
  
}

variable "docker_version" {
  description = "Specify Docker version"
  default = "20.20.1"
  
}