# VSP One SDS Block — Terraform Deployment Guide

Deploy Hitachi VSP One SDS Block (AWS Marketplace product) via Terraform, using CloudFormation as the underlying deployment engine.

---

## Overview

This Terraform configuration deploys the **Hitachi VSP One SDS Block** storage cluster on AWS. Since the product is distributed as an AWS Marketplace CloudFormation template (with Hitachi-owned nested stacks), Terraform manages the CloudFormation stack lifecycle rather than provisioning AWS resources directly.

**Marketplace Product:** `prod-4o3qqwmrr6yqe`
**Version:** `1.19.01.30`
**AWS Region:** `us-west-2`

---

## Directory Structure

```
.
├── main.tf                          # CloudFormation stack resource definition
├── provider.tf                      # AWS provider and Terraform version config
├── variable.tf                      # Variable declarations (no defaults)
└── terraform.tfvars                 # All deployment values — edit this file
```

---

## Prerequisites

### 1. Terraform Installed

```bash
terraform -version
```

If not installed (Amazon Linux / RHEL):

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install -y terraform
```

### 2. AWS Marketplace Subscription Active

The AWS account must have accepted the Marketplace terms for this product before Terraform can deploy it. Verify:

```bash
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

aws ssm get-parameter \
  --name /aws/service/marketplace/prod-4o3qqwmrr6yqe/version-1.19.01.30-0011 \
  --query "Parameter.Value" --output text
```

If this fails, go to the AWS Marketplace console, find the Hitachi VSP One SDS Block listing, and accept the subscription terms before proceeding.

### 3. IAM Permissions on the Role

The IAM role used by the EC2 instance (or CLI credentials) must have the following permissions attached. Ask your AWS account admin to attach these policies to the role:

```bash
aws iam attach-role-policy --role-name <YOUR_ROLE> \
  --policy-arn arn:aws:iam::aws:policy/AWSCloudFormationFullAccess

aws iam attach-role-policy --role-name <YOUR_ROLE> \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-role-policy --role-name <YOUR_ROLE> \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
```

> **Note:** `IAMFullAccess` is required when `iam_role_creation_mode = "Auto"`. If you prefer not to grant full IAM access, set `iam_role_creation_mode = "Manual"` in `terraform.tfvars` and supply an existing IAM role name in `iam_role_name_for_storage_cluster` — this skips all IAM resource creation entirely.

---

## Configuration

All deployment values are controlled from a single file:

### `terraform.tfvars`

```hcl
# ── Cluster Identity ──────────────────────────────────────────────────
cluster_name      = "VSPOneSDSBlock"       # Alphanumeric + hyphens, start with letter, max 20 chars
availability_zone = "us-west-2a"
billing_code      = "VSPOneSDSBlock"       # Cost monitoring tag
time_zone         = "UTC"

# ── Networking ────────────────────────────────────────────────────────
vpc_id                 = "vpc-xxxxxxxxxxxxxxxxx"      # VPC for the cluster
control_subnet_id      = "subnet-xxxxxxxxxxxxxxxxx"   # Control network subnet
control_network_cidr   = "10.0.1.0/24"               # CIDR of the control subnet
internode_subnet_id    = "subnet-xxxxxxxxxxxxxxxxx"   # Internode network subnet
compute_subnet_id      = "subnet-xxxxxxxxxxxxxxxxx"   # Compute network subnet
compute_ip_version     = "ipv4"                       # ipv4 or ipv4v6
compute_port_protocol  = "iSCSI"                      # iSCSI or NVMe/TCP

# ── Storage Node Configuration ────────────────────────────────────────
storage_node_instance_type = "r6i.8xlarge"
configuration_pattern      = "Mirroring Duplication ( 3 Nodes )"
drive_count                = "6"
physical_drive_capacity    = "Mirroring Duplication 1579 GiB"

# ── EBS Volume Encryption ─────────────────────────────────────────────
ebs_volume_encryption  = "disable"   # disable or enable
ebs_volume_kms_key_id  = "None"      # KMS Key ID if encryption is enabled

# ── IAM Role ──────────────────────────────────────────────────────────
iam_role_creation_mode            = "Auto"   # Auto = create new role, Manual = use existing
iam_role_name_for_storage_cluster = ""       # Required only if mode is Manual

# ── S3 Error Output ───────────────────────────────────────────────────
s3_uri = "s3://your-bucket/your-error-output-folder/"

# ── Marketplace Parameters (do not change these) ──────────────────────
image_id         = "/aws/service/marketplace/prod-4o3qqwmrr6yqe/version-1.19.01.30-0011"
mps3_bucket_name = "awsmp-cft-053155443450-1579814207723"
mps3_bucket_region = "us-east-1"
mps3_key_prefix  = "1116124c-bf19-4b4c-a208-f88e9b31df3b/d5ee2dc6-a777-40a4-b15d-ae4a4671f843/d0731770-73b0-48ec-a032-c90df04da543/"
```

### Finding your VPC and Subnet IDs

```bash
aws ec2 describe-vpcs \
  --query "Vpcs[].[VpcId,CidrBlock,Tags[?Key=='Name'].Value|[0]]" \
  --output table

aws ec2 describe-subnets \
  --query "Subnets[].[SubnetId,VpcId,CidrBlock,AvailabilityZone,Tags[?Key=='Name'].Value|[0]]" \
  --output table
```

---

## Deployment Steps

### Step 1 — Initialize

```bash
terraform init
```

### Step 2 — Validate

```bash
terraform validate
```

### Step 3 — Plan (preview, no changes made)

```bash
terraform plan
```

Review carefully — confirm it shows only a single resource to create (`aws_cloudformation_stack.vsp_one_sds_block_test`) and nothing unexpected.

### Step 4 — Apply

```bash
terraform apply
```

Deployment typically takes **20–40 minutes** — CFN needs to launch nested stacks, EC2 storage nodes, EBS volumes, and networking resources. Monitor progress in a separate terminal:

```bash
watch -n 30 'aws cloudformation describe-stacks \
  --stack-name test-PI-19-3-tf-trial \
  --query "Stacks[0].StackStatus"'
```

### Step 5 — Verify

```bash
terraform plan
```

A clean apply should show **zero changes**. Any diff means the deployed state doesn't match your config — fix the config, not the infrastructure.

---

## IAM Role Modes

| Mode | Behaviour | Requires |
|------|-----------|----------|
| `Auto` | Creates a new IAM role and policy for the storage cluster | `iam:CreateRole`, `iam:CreatePolicy`, `iam:CreateInstanceProfile` on the deploying role |
| `Manual` | Uses an existing IAM role — no IAM resources created | The role named in `iam_role_name_for_storage_cluster` must already exist with correct permissions |

**Recommended for test/shared environments:** use `Manual` and supply `SDSClusterRole` (or the role the existing `test-PI-19-3` stack used) to avoid needing broad IAM creation permissions.

---

## Configuration Patterns

| Pattern | Nodes | Protection |
|---------|-------|-----------|
| `Mirroring Duplication ( 3 Nodes )` | 3 | Mirroring |
| `Mirroring Duplication ( 6 Nodes )` | 6 | Mirroring |
| `Mirroring Duplication ( 9 Nodes )` | 9 | Mirroring |
| `Mirroring Duplication ( 12 Nodes )` | 12 | Mirroring |
| `Mirroring Duplication ( 15 Nodes )` | 15 | Mirroring |
| `Mirroring Duplication ( 18 Nodes )` | 18 | Mirroring |
| `HPEC 4D+2P ( 6 Nodes )` | 6 | HPEC |
| `HPEC 4D+2P ( 12 Nodes )` | 12 | HPEC |
| `HPEC 4D+2P ( 18 Nodes )` | 18 | HPEC |

> `configuration_pattern` and `physical_drive_capacity` must use matching protection types (both `Mirroring Duplication` or both `HPEC 4D+2P`).

---

## Troubleshooting

### ROLLBACK_FAILED — stuck stack

If Terraform errors with `ROLLBACK_FAILED`, the stack is stuck and needs manual recovery before retrying:

```bash
# Attempt rollback resume
aws cloudformation continue-update-rollback --stack-name test-PI-19-3-tf-trial

# If that also fails, skip the blocking resource
aws cloudformation continue-update-rollback \
  --stack-name test-PI-19-3-tf-trial \
  --resources-to-skip StorageClusterDuplication

# Then delete the stuck stack
aws cloudformation delete-stack --stack-name test-PI-19-3-tf-trial

# Confirm it's gone
aws cloudformation describe-stacks \
  --stack-name test-PI-19-3-tf-trial 2>&1 | grep -i "does not exist"
```

### Orphaned KeyPair blocking retry

After a failed attempt, CFN may leave an orphaned key pair that blocks the next run:

```bash
# List all key pairs
aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output table

# Delete the orphaned one
aws ec2 delete-key-pair --key-name test-PI-19-3-tf-trial-KeyPair
```

Always do this cleanup before retrying `terraform apply`.

### AccessDenied on IAM actions

If you see `iam:CreatePolicy` or `iam:CreateRole` denied, switch to Manual mode in `terraform.tfvars`:

```hcl
iam_role_creation_mode            = "Manual"
iam_role_name_for_storage_cluster = "SDSClusterRole"
```

### Getting real error reasons from CFN

```bash
aws cloudformation describe-stack-events \
  --stack-name <NESTED_STACK_NAME> \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED'].[LogicalResourceId,ResourceStatusReason]" \
  --output table
```

---

## Destroy

```bash
terraform destroy
```

> **Warning:** This will delete the CloudFormation stack and all storage nodes, EBS volumes, and data inside the cluster. Only run this if you're certain the cluster is no longer needed. There is no undo.

---

## Notes

- The `MPS3BucketName`, `MPS3BucketRegion`, and `MPS3KeyPrefix` values are fixed to the Marketplace product version and should not be changed unless you are upgrading to a new Marketplace version.
- This template is an AWS Marketplace wrapper — the actual storage cluster resources (EC2, EBS, IAM) are provisioned inside Hitachi's own nested CFN templates. Terraform manages the stack lifecycle but does not directly manage those inner resources.
