# Implement Doc from Hetzner to install Kubernetes Cluster
# https://community.hetzner.com/tutorials/install-kubernetes-cluster

# local$ hcloud network create --name kubernetes --ip-range 10.98.0.0/16
# local$ hcloud network add-subnet kubernetes --network-zone eu-central --type server --ip-range 10.98.0.0/16
# local$ hcloud server create --type cx11 --name master-1 --image ubuntu-18.04 --ssh-key <ssh_key_id> --network <network_id>
# local$ hcloud server create --type cx21 --name worker-1 --image ubuntu-18.04 --ssh-key <ssh_key_id> --network <network_id>
# local$ hcloud server create --type cx21 --name worker-2 --image ubuntu-18.04 --ssh-key <ssh_key_id> --network <network_id>
# local$ hcloud floating-ip create --type ipv4 --home-location nbg1
# local$ hcloud floating-ip create --type ipv6 --home-location nbg1  # (Optional)

provider "hcloud" {
  token = var.hcloud_token
}

# Create VPC netowrk and Subnet

resource "hcloud_network" "private" {
  name     = var.cluster_name
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

# Use existing ssh-key
resource "hcloud_ssh_key" "k8-ssh" {
  name       = "Admin SSH Key for Master and nodes"
  public_key = file(var.ssh_public_key)
}

resource "hcloud_server" "master" {
    count = var.master_count
    datacenter = var.datacenter
    name = "master-1"
    image = var.image
    server_type = var.master_type 
    ssh_keys = [hcloud_ssh_key.k8-ssh.id]

    network {
      network_id = hcloud_network.private.id
    }

    depends_on = [
    hcloud_network_subnet.subnet
  ]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file(var.ssh_private_key)
    }

    provisioner "file" {
      source      = "files/20-hetzner-cloud.conf"
      destination = "/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf"
    }

    provisioner "file" {
      source      = "files/prepareHost.sh"
      destination = "/root/prepareHost.sh"
    }

    provisioner "file" {
      source      = "files/master.sh"
      destination = "/root/master.sh"
    }

    provisioner "file" {
      source      = "files/calico.yaml"
      destination = "/root/calico.yaml"
    }
    
    provisioner "remote-exec" {
       inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/prepareHost.sh"]
    }

     provisioner "remote-exec" {
       inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/master.sh"]
    }
    
    provisioner "file" {
      source      = "files/00-cgroup-systemd.conf"
      destination = "/etc/systemd/system/docker.service.d/00-cgroup-systemd.conf"
    }

    provisioner "local-exec" {
      command = "${path.module}/files/get-kubeadm-token.sh"
      interpreter = ["bash"]
      working_dir = "${path.module}"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME    = "root"
      SSH_HOST        = hcloud_server.master.0.ipv4_address
      OUTDIR          = "${path.module}/local/"
    }
  }

}

resource "hcloud_floating_ip" "master" {
  type      = "ipv4"
  server_id = hcloud_server.master.0.id
}

resource "hcloud_server" "node" {
    count = var.node_count
    datacenter = var.datacenter
    name = "node-${count.index + 1}"
    image = var.image
    server_type = var.node_type
    ssh_keys = [hcloud_ssh_key.k8-ssh.id]

    network {
      network_id = hcloud_network.private.id
    }

      depends_on = [
        hcloud_network_subnet.subnet, hcloud_server.master.0
      ]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file(var.ssh_private_key)
    }

    provisioner "file" {
      source      = "files/20-hetzner-cloud.conf"
      destination = "/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf"
    }

    provisioner "file" {
      source      = "files/prepareHost.sh"
      destination = "/root/prepareHost.sh"
    }

    provisioner "file" {
      source      = "files/node.sh"
      destination = "/root/node.sh"
    }

    provisioner "file" {
      source      = "${path.module}/local/kubeadm_join_command.out"
      destination = "/var/tmp/kubeadm_join_command.out"

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key)
    }
  }
    
    provisioner "remote-exec" {
       inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/prepareHost.sh"]
    }

    provisioner "remote-exec" {
       inline = ["DOCKER_VERSION=${var.docker_version} KUBERNETES_VERSION=${var.kubernetes_version} bash /root/node.sh"]
    }
}