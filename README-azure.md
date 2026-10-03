# Azure AKS Infrastructure and Pipeline

This directory contains the Azure equivalent of the AWS EKS infrastructure. It provisions an Azure Kubernetes Service (AKS) cluster with Terraform and deploys applications through GitHub Actions using Azure Active Directory federated credentials.

## Architecture

- A VNet has subnets for AKS nodes (private) and public access.
- Terraform state is stored in an encrypted Azure Storage Account.
- AKS uses a managed cluster with system-assigned identity, spot instances for cost savings, and Container Insights monitoring.
- Azure Container Registry stores container images.
- GitHub Actions authenticate to Azure using federated credentials (no service principal secrets stored).

## Prerequisites

1. Install Terraform, Azure CLI, Docker, kubectl, and Helm
2. Authenticate to Azure:
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```
3. Create a Storage Account for Terraform state:
   ```bash
   az storage account create \
     --name yourterraformstate \
     --resource-group your-rg \
     --sku Standard_LRS \
     --encryption-services blob

   az storage container create \
     --name tfstate \
     --account-name yourterraformstate \
     --auth-mode login
   ```

## Setup

1. Copy `infra-azure/backend.hcl.example` to `infra-azure/backend.hcl` and fill in:
   - `storage_account_name`: Your storage account name
   - `container_name`: Container name (default: tfstate)
   - `key`: State file path
   - `resource_group_name`: Resource group containing storage account
   - `subscription_id`: Your Azure Subscription ID
   - `tenant_id`: Your Azure Tenant ID

2. Copy `infra-azure/terraform.tfvars.example` to `infra-azure/terraform.tfvars` and set:
   - `azure_subscription_id`: Your Azure Subscription ID
   - `azure_tenant_id`: Your Azure Tenant ID
   - `github_owner`: Your GitHub organization
   - `github_repository`: Your repository name

3. Run Terraform:
   ```bash
   cd infra-azure
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

## GitHub Actions Configuration

After deployment, add these repository variables to your GitHub repository:

| Variable | Description | Example |
|----------|-------------|---------|
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_CLIENT_ID` | Service Principal App ID | `12345678-1234-1234-1234-123456789012` |
| `TF_STATE_SA` | Storage account name | `yourterraformstate` |
| `TF_STATE_CONTAINER` | Storage container | `tfstate` |
| `TF_STATE_RG` | Resource group | `your-rg` |
| `ACR_LOGIN_SERVER` | ACR login server | `myregistry.azurecr.io` |
| `AKS_CLUSTER_NAME` | AKS cluster name | `keyless-aks` |
| `AKS_RESOURCE_GROUP` | AKS resource group | `keyless-aks-rg` |

## Cost Estimate (eastus)

| Resource | AWS (ap-northeast-1) | Azure (eastus) | GCP (us-central1) |
|----------|----------------------|----------------|-------------------|
| Control Plane | $73/mo (EKS) | **$0** (AKS free) | **$0** (GKE free) |
| Nodes (2x DS2_v2) | ~$70/mo | ~$50/mo (spot) | ~$52/mo (preemptible) |
| VNet NAT Gateway | ~$33/mo each | ~$33/mo (Standard) | **$0** (Cloud NAT free) |
| Container Registry | ~$2/mo (ECR) | ~$1.50/mo (ACR) | ~$0.10/mo |
| State Backend | ~$0.50/mo (S3) | ~$0.01/mo (Blob) | **Free** (GCS) |
| **Total (approx)** | **~$270/mo** | **~$120/mo** | **~$115/mo** |

**Azure is ~56% cheaper than AWS, GCP is ~57% cheaper**

## Local Testing

```bash
# Validate Terraform
terraform -chdir=infra-azure fmt -check -recursive
terraform -chdir=infra-azure validate

# Test Kubernetes manifests
helm lint k8s/helm/app

# Build Docker image locally
docker build -t test:local app

# Run tests
go test ./app/...
```

## Destroy

```bash
terraform -chdir=infra-azure destroy
```

Note: The storage account for state is not destroyed by Terraform.

## Key Differences from AWS

| AWS | Azure | GCP |
|-----|-------|-----|
| EKS | AKS (free control plane) | GKE (free control plane) |
| ECR | ACR | Artifact Registry |
| IAM OIDC Provider | Federated Credentials | Workload Identity Federation |
| NAT Gateway | NAT Gateway (Standard SKU) | Cloud NAT (free) |
| S3 + DynamoDB | Blob Storage (no locking) | Cloud Storage (no locking) |
| Managed Node Groups | AKS Node Pool with spot | GKE Node Pool with preemptible |

## Files

```
infra-azure/
├── main.tf                    # Main Terraform configuration
├── backend.tf                 # Backend configuration
├── backend.hcl.example        # Backend configuration example
├── providers.tf               # Provider definitions
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Variables example
├── modules/
│   ├── vnet/                  # VNet and networking
│   ├── aks/                   # AKS cluster and node pool
│   ├── container-registry/    # Container registry
│   └── iam/                   # IAM and federated credentials
```

## Troubleshooting

- **Federated credentials not working**: Ensure the subject matches exactly: `repo:org/repo:ref:refs/heads/main`
- **AKS node pool stuck**: Spot instances may be evicted; consider increasing max_nodes
- **State locking issues**: Azure Blob Storage uses lease-based locking
- **ACR auth failures**: Ensure AcrPull/AcrPush roles are assigned to the service principal
