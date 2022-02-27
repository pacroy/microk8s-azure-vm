# Single Node MicroK8s on Azure VM

[![Lint Code Base](https://github.com/pacroy/microk8s-azure-vm/actions/workflows/linter.yml/badge.svg?branch=main)](https://github.com/pacroy/microk8s-azure-vm/actions/workflows/linter.yml)

This [Terraform](https://www.terraform.io/) project deploys and configures a single node [MicroK8s](https://microk8s.io/) cluster on a virtual machine in Azure cloud. The cluster can run small workloads that are non-critical while minimizing cost.

## Components

The following resources will be created:

- A virtual network with one `default` subnet associated with a network security group that allow:
  - Incoming SSH (port 22) and kubectl (port 16443) traffics from the specified IP address or range to the VM
  - Incoming HTTP and HTTPs traffics from the Internet to randomized NodePorts of the nginx ingress controller
- A Linux virtual machine (Ubuntu 20.04 LTS) deployed in the `default` subnet.
- A public IP for the public load balancer.
- A public load balancer that will route:
  - Incoming SSH traffics from a ramdom port (20000-24999) to VM random SSH port (10001-16442).
  - Incoming kubectl traffics from a ramdom port (25000-29999) to VM port 16443.
  - Incoming HTTP traffics to a random port (30000-31999) on the VM.
  - Incoming HTTPS traffics to a random port (32000-32767) on the VM.
  - Outbound traffics from the VM to the Internet via the public IP

The Linux virtual machine will also be initialized using [cloud-init](https://cloudinit.readthedocs.io/en/latest/) configuration that perform the following:

- Update and upgrade software packages
- Change SSH port
- Install the latest Kubernetes version of MicroK8s
- Enable dns, storage, and helm3 plugin services
- Configure the cluster IP and DNS and generate KUBECONFIG file
- Use [Helm](https://helm.sh/) to install:
  - [ingress-nginx](https://kubernetes.github.io/ingress-nginx/)
  - [cert-manager](https://cert-manager.io/docs/)
  - [Let's Encrypt](https://letsencrypt.org/) Production ACME [cluster-issuer](https://github.com/pacroy/cluster-issuer-helm)
- Configure unattended OS upgrades
- Setup automatic weekly reboot on Sunday at 00:30 UTC

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads)
- An active Azure subscription, create a resource group you want to deploy to
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), [log in to Azure Cloud](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) and [change to the subscription](https://docs.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli#change-the-active-subscription) you want to deploy to
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- Clone this repository to your computer

## Usage

1. Initialize Terraform

    ```sh
    terraform init
    ```

2. Create a new workspace, if you want

    ```sh
    terraform workspace new myk8s
    ```

3. Apply by giving the following variables:

    - Resource group name.
    - Suffix that will be use to name your resources, will be randomly generated if omit.
    - Public ip address of your computer to securely allow only you to connect and control the VM/cluster.
    - Email for Let's Encrypt notifications of certificate expirations

    _See all available variables in [variables.tf](variables.tf)_

    ```sh
    terraform apply \
        -var resource_group_name=rg-myk8s \
        -var suffix=myk8s \
        -var ip_address=$(curl -s ipv4.icanhazip.com) \
        -var email=youremail@domain.com
    ```

    Enter `yes` to confirm to proceed.

4. Once completed, create SSH key file as you need this to SSH into the VM.

    ```sh
    terraform output -raw private_key > id_rsa
    chmod 600 id_rsa
    ```

5. SSH into the VM. Note: You might need to wait a bit before you can connect.

    ```sh
    SSH_PORT="$(terraform output ssh_port)"
    VM_FQDN="$(terraform output -json public_ip | jq -r ".fqdn")"
    echo "SSH_PORT: $SSH_PORT"
    echo "VM_FQDN : $VM_FQDN"
    ssh -i id_rsa -l azureuser -p $SSH_PORT $VM_FQDN
    ```

    Enter `yes` to confirm to connect.

6. In SSH session, follow cloud-init logs.

    ```sh
    tail +1f /var/log/cloud-init-output.log
    ```

    Wait until it finishes when you see something like this:

    ```console
    Cloud-init v. 21.4-0ubuntu1~20.04.1 running 'modules:final' at Xxx, nn Mmm YYYY hh:mm:ss +0000. Up nn.dd seconds.
    Cloud-init v. 21.4-0ubuntu1~20.04.1 finished at Xxx, nn Mmm YYYY hh:mm:ss +0000. Datasource DataSourceAzure [seed=/dev/sr0].  Up nnn.dd seconds
    ```

    Press <kbd>Ctrl + C</kbd> to exit from the log. Then press <kbd>Ctrl + D</kbd> to quit the SSH session.

7. Download KUBECONFIG file.

    ```sh
    scp -i id_rsa -P $(terraform output ssh_port) azureuser@$(terraform output -json public_ip | jq -r ".fqdn"):admin.config admin.config
    ```

8. Note the FQDN and port of your VM.

    ```sh
    echo "server: $(terraform output -json public_ip | jq -r ".fqdn"):$(terraform output kubectl_port)"
    ```

9. Edit the `admin.config` file that you download in 7 and update the field `clusters.cluster.server` with the hostname and port you note in 8.

    ```yaml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: xxx==
        server: https://xxxxxxx.southeastasia.cloudapp.azure.com:2xxxx
    ```

10. Test kubectl connection.

    ```sh
    export KUBECONFIG=admin.config
    kubectl get nodes
    ```

    You should see the only node of your MicroK8s cluster and it is now ready for your use.

11. You can see your server ingress public IP address using this command:

    ```sh
    echo "IP: $(terraform output -json public_ip | jq -r ".ip_address")"
    ```
