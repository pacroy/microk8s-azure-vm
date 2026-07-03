# Copilot Instructions for microk8s-azure-vm

## Project Overview

This repository contains a Terraform project that deploys and configures a single-node MicroK8s Kubernetes cluster on an Azure VM. The infrastructure includes networking (Virtual Network, Network Security Groups, Public IP), a Linux VM (Ubuntu 20.04), a public load balancer, and cloud-init configuration for automatic setup of MicroK8s, ingress-nginx, cert-manager, and Let's Encrypt.

## Build, Test, and Lint Commands

### Format Check
```sh
terraform fmt -recursive -check
```

### Format Fix
```sh
terraform fmt -recursive
```

### Initialize Terraform (required before validate/plan/apply)
```sh
terraform init
```

### Validate Configuration
```sh
terraform validate
```

### Plan Infrastructure Changes
```sh
terraform plan
```

### Apply Infrastructure Changes
```sh
terraform apply
```

### View Linter Status
The project uses a shared GitHub Actions linter workflow (from `pacroy/gh-common-workflows`). To verify code style locally before pushing:
- Run `terraform fmt -recursive -check` to check formatting
- The linter will run automatically on push and PR

## Architecture

The Terraform code is organized into five main files, each handling a specific aspect:

### Logical Flow
1. **providers.tf** - Declares Terraform version requirements and provider configurations (azurerm, random, tls, cloudinit, http)
2. **variables.tf** - Defines all input variables with defaults (resource group, IP restrictions, VM size, etc.)
3. **locals.tf** - Computes derived values and imports the Azure naming module for consistent resource naming
4. **main.tf** - Creates core infrastructure (NSG rules, Virtual Network, NIC, VM with cloud-init) and data sources
5. **loadbalancer.tf** - Creates public IP, load balancer, and inbound NAT rules for SSH, kubectl, HTTP/HTTPS
6. **outputs.tf** - Exports important values (public IP, FQDN, ports, keys)

### Key Components
- **Naming Module**: Uses `Azure/naming/azurerm` to standardize resource names with a suffix
- **Random Port Generation**: Randomizes SSH (20000-24999), kubectl (25000-29999), HTTP (30000-31999), and HTTPS (32000-32767) ports on the load balancer
- **Cloud-init Configuration**: Template file `init.cfg.tftpl` defines automatic provisioning (MicroK8s installation, DNS/storage/helm3 setup, ingress-nginx, cert-manager, Let's Encrypt)
- **Network Security**: Restrictive NSG rules allow SSH/kubectl only from specified IP(s), but HTTP/HTTPS from the internet

## Key Conventions

### File Organization
- Terraform files use the standard naming convention: `providers.tf`, `variables.tf`, `locals.tf`, `main.tf`, etc.
- Resource naming uses the Azure naming module with a suffix for consistent prefixing
- Cloud-init configuration is in `init.cfg.tftpl` using template syntax for variable substitution

### Naming Patterns
- Resources are named with a common suffix (default: random 7-character ID) for easy identification and cleanup
- Module outputs reference the naming module (e.g., `module.naming.virtual_network.name`)
- Local values are heavily used to avoid repetition and centralize configuration logic

### Port Allocation Strategy
- Ports are randomized in specific ranges to avoid conflicts:
  - **SSH**: 20000-24999 (load balancer) → 10001-16442 (VM)
  - **kubectl**: 25000-29999
  - **HTTP**: 30000-31999
  - **HTTPS**: 32000-32767
- These ranges prevent collisions with other services and are documented in the README

### Configuration via Variables
- Critical inputs (resource group, IP restrictions) are defined as variables with sensible defaults
- The `ip_address_list` variable supersedes `ip_address` if both are provided (check for null/coalesce patterns)
- Optional features are controlled via boolean variables (e.g., `allow_kubectl_from_azurecloud`)

### Cloud-init Configuration
- The template uses variable interpolation with `${variable_name}` syntax
- MicroK8s plugins (dns, hostpath-storage, helm3) are enabled in the init phase
- Helm repositories are added and ingress-nginx/cert-manager are installed automatically
- Certificate templates are updated dynamically with the correct FQDN and public IP

### Local Values
- `locals.tf` uses coalesce patterns to provide sensible defaults and handle optional inputs
- Computed values (like port numbers and FQDN) are centralized in locals to ensure consistency
- Private IP allocation is static using `cidrhost()` function

## Common Tasks

### Adding a New Security Rule
Add to `main.tf` following the pattern of existing rules. Use locals for derived port values and ensure the rule has a unique priority number.

### Changing VM Size or OS Image
Update `variables.tf` for the size and modify `main.tf` where the image reference is defined.

### Modifying Cloud-init Configuration
Edit `init.cfg.tftpl` using template variable syntax (e.g., `${fqdn}`, `${ssh_vm_port}`). Changes are applied on VM creation; existing VMs require manual updates or recreation.

### Testing Changes Locally
After running `terraform init`, use:
- `terraform fmt -recursive -check` to verify formatting
- `terraform validate` to check configuration syntax
- `terraform plan` to preview changes (requires Azure credentials)
