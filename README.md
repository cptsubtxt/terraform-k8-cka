# terraform-k8-cka

Setup the CKA Environment for Labs with Terraform.

**Note:** This version has a problem with joining kube nodes. You can join worker nodes in a manual fashion.

## Get Terraform

Download [Terraform] and install for your OS.

## Clone repo

`git clone https://github.com/cptsubtxt/terraform-k8-cka.git`

Change into the directory created (e.g. on Linux cd <>)

## Create terraform.tfvars

Fill in values that suites your use-case, e.g.:

```console
hcloud_token = "Your Project API Token"
master_type = "cx21"
master_count = 1
node_type = "cx21"
node_count = 2
kubernetes_version = "1.22.3"
docker_version = "20.20.1"
ssh_private_key = "ssh-keys/ssh-key-rsa-learnk8"
ssh_public_key = "ssh-keys/ssh-key-rsa-learnk8.pub"
```


## Create some folders used

In the project folder create folder ssh-keys and local. This folders won't be synced with git as they are excluded to make s

## Create SSH Keys

Next we have to create a SSH Key for adding to our Server that we will provision in the next place.

For Windows we follow the infos presented under [Generate SSH Keys in Windows]

For *ix Systems we make use of the steps presented under [Generate SSH Keys with ssh-gen] with a Name for example an Emailaddress or a Label for later steps

e.g.

`ssh-keygen -f ssh-keys/ssh-key-rsa-learnk8 -t rsa -b 4096 -C "nomail@somedomain.com"`


## Run Terraform

`terraform init`

`terraform plan`

`terraform apply`


**Attention** This step will create resources in Hetzner Cloud that will be charged!

## Test your installation

During Installation the admin.config from Master Node will be fetched and copied over to local Folder on your Computer.

Change to local folder in your Terraform Project and issue:

`$ export KUBECONFIG=${PWD}/admin.conf`

Test your installation with:

`$ kubectl cluster-info`

Now you should be able to issue all kubectl commands to the newly created cluster.


[Generate SSH Keys in Windows]: https://www.ssh.com/academy/ssh/putty/windows/puttygen
[Generate SSH Keys with ssh-gen]: https://www.ssh.com/academy/ssh/keygen
[Terraform]: https://www.terraform.io