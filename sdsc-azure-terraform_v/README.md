# SDSC Deployment on Azure using Terraform

A quick start guide for deploying an SDSC (Software Defined Storage Controller) cluster on Microsoft Azure using Terraform.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Step 1 — Download Terraform Configuration](#step-1--download-terraform-configuration)
  - [Step 2 — Configure Deployment Variables](#step-2--configure-deployment-variables)
  - [Step 3 — Initialize Terraform](#step-3--initialize-terraform)
  - [Step 4 — Validate Deployment Plan](#step-4--validate-deployment-plan)
  - [Step 5 — Deploy the SDSC Cluster](#step-5--deploy-the-sdsc-cluster)
  - [Step 6 — Monitor Deployment](#step-6--monitor-deployment)
  - [Step 7 — Access SDSC Cluster](#step-7--access-sdsc-cluster)
- [Destroy Deployment](#destroy-deployment)
- [Summary](#summary)

---

## Overview

This guide provides a quick walkthrough for deploying an SDSC cluster on Microsoft Azure using Terraform. It covers prerequisites, configuration steps, Terraform commands, and verification of the deployment.

---

## Prerequisites

Before you begin, ensure you have the following:

- Active Microsoft Azure subscription with permissions to create resources
- Access to the SDSC Terraform deployment repository
- Terraform installed
- Azure CLI installed and authenticated
- Existing Virtual Network and subnets prepared for SDSC deployment
- Storage account details and billing code

> **Note:** Please refer to the **official SDSC Azure documentation** to understand the required permissions.

---

## Quick Start

### Step 1 — Download Terraform Configuration

Clone or download the Terraform configuration repository:

```bash
git clone <repository-url>
cd <repository-directory>
```

Verify the files are present:

```bash
ls
```

Locate the main configuration file:

```
terraform.tfvars
```

---

### Step 2 — Configure Deployment Variables

Open `terraform.tfvars` and update the following required variables:

| Variable | Description |
|---|---|
| `cloud_region` | Azure region for deployment |
| `subscription_id` | Azure subscription ID |
| `resource_group_name` | Resource group name |
| `sdsc_cluster_name` | Name for the SDSC cluster |
| `storage_account_name` | Storage account name |
| `billing_code` | Billing code |
| `virtual_network` | Virtual network name |
| `subnet_name` | Subnet name |
| `node_count` | Number of nodes |
| `vm_size` | VM size/type |

> Refer to SDSC official documentation for supported node types and sizing. Save the file after updating values.

---

### Step 3 — Initialize Terraform

Run the following command to initialize Terraform and download required providers and modules:

```bash
terraform init
```

---

### Step 4 — Validate Deployment Plan

Preview the resources that will be created:

```bash
terraform plan
```

Review the output carefully to ensure the resources match your expected configuration before proceeding.

---

### Step 5 — Deploy the SDSC Cluster

Apply the Terraform configuration:

```bash
terraform apply
```

When prompted, type `yes` to confirm.

```
Do you want to perform these actions? yes
```

> Terraform will start provisioning resources. Infrastructure creation takes a few minutes. After Terraform shows **Apply Complete**, SDSC cluster initialization begins and typically takes **20–30 minutes**.

---

### Step 6 — Monitor Deployment

1. Open the **Azure Portal**
2. Search for the **Resource Group** defined in `terraform.tfvars`
3. Navigate to: `Resource Group → Deployments`
4. Select the installation deployment item to view status

The status will initially show **In Progress**. After approximately **20–30 minutes** it will change to **Completed**.

---

### Step 7 — Access SDSC Cluster

1. In Azure Portal, search for **Load Balancers**
2. Locate the newly created load balancer that contains the cluster name prefix
3. Copy the **Frontend IP address**
4. Paste the IP into your browser

If the login page loads successfully, the SDSC cluster is deployed and accessible. You can now log in and perform storage management tasks.

---

## Destroy Deployment

To remove the deployment and clean up all resources:

**Step 1 — Remove resource locks:**
1. Go to the Resource Group in Azure Portal
2. Navigate to `Settings → Locks`
3. Remove all resource locks

**Step 2 — Run Terraform destroy:**

```bash
terraform destroy
```

Type `yes` when prompted. Terraform will delete all created resources.

> ⚠️ **Warning:** This action is irreversible. All provisioned resources will be permanently deleted.

---

## Summary

| Step | Action |
|---|---|
| 1 | Clone Terraform repository |
| 2 | Configure `terraform.tfvars` |
| 3 | Run `terraform init` |
| 4 | Run `terraform plan` |
| 5 | Run `terraform apply` |
| 6 | Monitor deployment in Azure Portal (20–30 min) |
| 7 | Access SDSC via Load Balancer IP |
| Optional | Run `terraform destroy` to clean up |

---

## Related Resources

- [Official SDSC Azure Documentation](#)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)