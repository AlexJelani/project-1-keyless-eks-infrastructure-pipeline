# GCP GKE Infrastructure and Pipeline

This directory contains the GCP equivalent of the AWS EKS infrastructure. It provisions a Google Kubernetes Engine (GKE) cluster with Terraform and deploys applications through GitHub Actions using Workload Identity Federation.

## Architecture

- A multi-AZ VPC has public subnets for external access and private subnets for GKE nodes.
- Terraform state is stored in an encrypted Cloud Storage bucket.
- GKE uses a private cluster with Workload Identity enabled, managed node pools with preemptible instances, and Cloud Logging/Monitoring.
- Artifact Registry stores container images with lifecycle policies.
- GitHub Actions authenticate to GCP using Workload Identity Federation (no service account keys stored).

## Prerequisites

1. Install Terraform, Google Cloud SDK, Docker, kubectl, and Helm
2. Authenticate to GCP:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```
3. Enable required APIs:
   ```bash
   gcloud services enable \
     container.googleapis.com \
     artifactregistry.googleapis.com \
     iam.googleapis.com \
     iamcredentials.googleapis.com \
     compute.googleapis.com
   ```
4. Create a Cloud Storage bucket for Terraform state:
   ```bash
   gsutil mb -p YOUR_PROJECT_ID -l us-central1 gs://YOUR_STATE_BUCKET/
   gsutil versioning set on gs://YOUR_STATE_BUCKET/
   ```

## Setup

1. Copy `infra-gcp/backend.hcl.example` to `infra-gcp/backend.hcl` and fill in:
   - `bucket`: Your Cloud Storage bucket name
   - `prefix`: State file prefix (optional)
   - `project`: Your GCP Project ID
   - `region`: Region (default: us-central1)

2. Copy `infra-gcp/terraform.tfvars.example` to `infra-gcp/terraform.tfvars` and set:
   - `gcp_project_id`: Your GCP Project ID
   - `github_owner`: Your GitHub organization
   - `github_repository`: Your repository name

3. Run Terraform:
   ```bash
   cd infra-gcp
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

## GitHub Actions Configuration

After deployment, add these repository variables to your GitHub repository:

| Variable | Description | Example |
|----------|-------------|---------|
| `GCP_PROJECT_ID` | GCP Project ID | `my-project-123` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | WIF pool provider | `projects/123456/locations/global/workloadIdentityPools/github-pool/keyless-eks/providers/github-dev` |
| `GCP_SERVICE_ACCOUNT` | Service account email | `github-actions-dev-keyless-eks@my-project-123.iam.gserviceaccount.com` |
| `TF_STATE_BUCKET` | Cloud Storage bucket | `my-terraform-state-bucket` |
| `ARTIFACT_REGISTRY_REPO` | Artifact Registry repo | `keyless-eks-app` |
| `GKE_CLUSTER_NAME` | GKE cluster name | `keyless-eks` |
| `GKE_CLUSTER_LOCATION` | GKE cluster location | `us-central1` |

## Cost Estimate (us-central1)

| Resource | AWS (ap-northeast-1) | GCP (us-central1) |
|----------|----------------------|-------------------|
| Control Plane | $73/mo (EKS) | **$0** (GKE free) |
| Nodes (2x e2-medium) | ~$70/mo | ~$52/mo (preemptible) |
| VPC NAT Gateway | ~$33/mo each | **$0** (Cloud NAT free) |
| Container Registry | ~$2/mo (ECR) | ~$0.10/mo (Artifact Registry) |
| State Backend | ~$0.50/mo (S3) | **Free** (GCS standard) |
| **Total (approx)** | **~$270/mo** | **~$115/mo** |

**Estimated savings: ~57% with GCP**

## Local Testing

```bash
# Validate Terraform
terraform -chdir=infra-gcp fmt -check -recursive
terraform -chdir=infra-gcp validate

# Test Kubernetes manifests
helm lint k8s/helm/app

# Build Docker image locally
docker build -t test:local app

# Run tests
go test ./app/...
```

## Destroy

```bash
terraform -chdir=infra-gcp destroy
```

Note: The Cloud Storage bucket for state is not destroyed by Terraform.

## Key Differences from AWS

| AWS | GCP |
|-----|-----|
| EKS | GKE (free control plane) |
| ECR | Artifact Registry |
| IAM OIDC Provider | Workload Identity Federation |
| NAT Gateway | Cloud NAT (free) |
| S3 + DynamoDB | Cloud Storage (no locking needed) |
| Managed Node Groups | GKE Node Pool with preemptible |
| AWS EKS access entries | Kubernetes RBAC + IAM bindings |

## Files

```
infra-gcp/
├── main.tf                    # Main Terraform configuration
├── backend.tf                 # Backend configuration
├── backend.hcl.example        # Backend configuration example
├── providers.tf               # Provider definitions
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Variables example
├── modules/
│   ├── vpc/                   # VPC and networking
│   ├── gke/                   # GKE cluster and node pool
│   ├── artifact-registry/     # Container registry
│   └── iam/                   # IAM and Workload Identity
```

## Troubleshooting

- **Workload Identity not working**: Check that `workload_identity_config` is enabled and the service account has `roles/iam.workloadIdentityUser`
- **GitHub Actions auth fails**: Ensure the repository and branch conditions match exactly
- **Node pool stuck**: Preemptible instances may be evicted; consider increasing max_nodes
- **State locking issues**: GCS uses object versioning instead of DynamoDB
