# Single Node MicroK8s on Azure VM

[![Lint Code Base](https://github.com/pacroy/microk8s-azure-vm/actions/workflows/linter.yml/badge.svg?branch=main)](https://github.com/pacroy/microk8s-azure-vm/actions/workflows/linter.yml)

This [Terraform](https://www.terraform.io/) project deploys and configures a single node [MicroK8s](https://microk8s.io/) cluster on single virtual machine in Azure cloud. The cluster can run small workloads that are non-critical while minimizing cost.

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

### A. Create Terraform Workspace

1. Go to [Terraform Cloud](https://app.terraform.io/) and create a new workspace.

2. Choose `CLI-driven workflow`.

3. Name your workspace and click `Create workspace`.

### B. Execute Apply

There are 2 ways to execute your workspace:

- [Remote Execution](#remote-execution)
- [Local Execution](#local-execution)

#### Remote Execution

Use this method if you have [Azure service principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) with client ID and secret. Otherwise, use [Local Execution](#local-execution).

1. In your Terraform workspace, go to *Variables*.

2. Add the following `Terraform variables`:

    | Variable            | Description                                                         |
    | ------------------- | ------------------------------------------------------------------- |
    | resource_group_name | Resource group name to provision all resources.                     |
    | suffix              | Suffix of all resource names.                                       |
    | ip_address          | IP address or range to allow access to the control ports of the VM. |

    *Note: See all variables in [variables.tf](variables.tf)*

3. Add the following `Environment variables`:

    | Variable            | Description                                                                                     |
    | ------------------- | ----------------------------------------------------------------------------------------------- |
    | ARM_CLIENT_ID       | Azure AD application ID of  the service principal that have permissions to provision resources. |
    | ARM_CLIENT_SECRET   | Azure AD application secret. Dont' forget to mark `Sensitive`.                                  |
    | ARM_SUBSCRIPTION_ID | Azure subscription ID.                                                                          |
    | ARM_TENANT_ID       | Azure tenant ID.                                                                                |

4. In your terminal, log in Terraform cloud.

    ```sh
    terraform login
    ```

5. Configure the following environment variables:

    ```sh
    export TF_CLOUD_ORGANIZATION="your_terraform_cloud_org"
    export TF_WORKSPACE="your_workspace_name"
    ```

6. Initialize.

    ```sh
    terraform init
    ```

7. Apply.

    ```sh
    terraform apply
    ```

#### Local Execution

Use this method if you use your personal credential to log in Azure.

1. In your Terraform workspace, go to *Settings* -> *General* and change *Execution Mode* to `Local`.
2. In your terminal, log in to Azure using `az login` command.
3. Make sure you switch to the right subscription.

    ```sh
    az account set --subscription "your_subscription_name"
    ```

4. Log in Terraform cloud.

    ```sh
    terraform login
    ```

5. Configure the following environment variables:

    ```sh
    export TF_CLOUD_ORGANIZATION="your_terraform_cloud_org"
    export TF_WORKSPACE="your_workspace_name"
    ```

6. Initialize.

    ```sh
    terraform init
    ```

7. Apply.

    ```sh
    terraform apply -var resource_group_name="your_resource_group" -var suffix="your_instance_suffix"
    ```

    If you want to specify your IP address ranges, add `-var ip_address_list` like this:

    ```sh
    terraform apply -var resource_group_name="your_resource_group" -var suffix="your_instance_suffix" -var ip_address_list='["1.2.3.4/24","5.6.7.8/24"]'
    ```

### C. Configure and Connect

1. Once apply completed, create SSH key file as you need this to SSH into the VM.

    ```sh
    terraform output -raw private_key > id_rsa
    chmod 600 id_rsa
    ```

2. SSH into the VM. Note: You might need to wait a bit before you can connect.

    ```sh
    SSH_PORT="$(terraform output ssh_port)"
    VM_FQDN="$(terraform output -json public_ip | jq -r ".fqdn")"
    echo "SSH_PORT: $SSH_PORT"
    echo "VM_FQDN : $VM_FQDN"
    ssh -i id_rsa -l azureuser -p $SSH_PORT $VM_FQDN
    ```

    Enter `yes` to confirm to connect.

3. In SSH session, follow cloud-init logs.

    ```sh
    tail +1f /var/log/cloud-init-output.log
    ```

    Wait until it finishes when you see something like this:

    ```console
    Cloud-init v. 21.4-0ubuntu1~20.04.1 running 'modules:final' at Xxx, nn Mmm YYYY hh:mm:ss +0000. Up nn.dd seconds.
    Cloud-init v. 21.4-0ubuntu1~20.04.1 finished at Xxx, nn Mmm YYYY hh:mm:ss +0000. Datasource DataSourceAzure [seed=/dev/sr0].  Up nnn.dd seconds
    ```

    Press <kbd>Ctrl + C</kbd> to exit from the log. Then press <kbd>Ctrl + D</kbd> to quit the SSH session.

4. Download KUBECONFIG file.

    ```sh
    scp -i id_rsa -P $(terraform output ssh_port) azureuser@$(terraform output -json public_ip | jq -r ".fqdn"):admin.config admin.config
    ```

5. Note the FQDN and port of your VM.

    ```sh
    echo "server: https://$(terraform output -json public_ip | jq -r ".fqdn"):$(terraform output kubectl_port)"
    ```

6. Edit the `admin.config` file that you download in 7 and update the field `clusters.cluster.server` with the hostname and port you note in 8.

    ```yaml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: xxx==
        server: https://xxxxxxx.southeastasia.cloudapp.azure.com:2xxxx
    ```

7. Test kubectl connection.

    ```sh
    export KUBECONFIG=admin.config
    kubectl get nodes
    ```

    You should see the only node of your MicroK8s cluster and it is now ready for your use.

8. You can get your server ingress public IP address using this command:

    ```sh
    echo "IP: $(terraform output -json public_ip | jq -r ".ip_address")"
    ```

9. Configure your DNS record to point to the IP address accordingly.

## Troubleshooting

### EncryptionAtHost feature is not enabled

Use this command to register EncryptionAtHost within your subscription.

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
```

Use this command to check the state. Wait until it changes from `Registering` to `Registered`.

```sh
az feature show --namespace Microsoft.Compute --name EncryptionAtHost
```

Once the state becomes registered, use this command again to ensure the new settings is propagated throughtout the subscription.

```sh
az provider register -n Microsoft.Compute
```

Reapply again.

### Display cloud-init Output Log

SSH into the VM and execute the command below.

```sh
tail +1f /var/log/cloud-init-output.log
```

### Display unattended-upgrades Log

SSH into the VM and execute the command below.

```sh
# Display upgrade log
sudo tail -F /var/log/apt/history.log

# Display output log
sudo tail -F /var/log/apt/term.log
```

### Identify hostpath Storage Location

SSH into the VM and execute the command below then look for `Path` within `Pod Template`/`Volumes`/`pv-volume`.

```sh
sudo microk8s kubectl describe deploy/hostpath-provisioner -n kube-system
```

### Display the Microk8s status

SSH into the VM and execute the command below.

```sh
sudo microk8s status
```

### Start and Stop the Cluster

SSH into the VM and execute either command below.

```sh
sudo microk8s start
sudo microk8s stop
```

### Display Number of Upgradable Packages

SSH into the VM and execute the command below.

```sh
/usr/lib/update-notifier/apt-check --human-readable
```
