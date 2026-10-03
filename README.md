# Keyless EKS Infrastructure and Pipeline

This repository provisions an AWS EKS cluster with Terraform and deploys a small Go service through GitHub Actions. AWS credentials are never stored in GitHub: workflows exchange a GitHub OIDC token for a short-lived IAM role session.

## Architecture

- A multi-AZ VPC has public subnets for load balancers and private subnets for EKS nodes.
- Terraform state is stored in an encrypted, versioned S3 bucket with DynamoDB locking.
- EKS uses managed node groups, control-plane logs, KMS envelope encryption, and EKS access entries.
- ECR uses immutable image tags, scan-on-push, and a lifecycle policy.
- The deployment workflow builds the image, pushes it to ECR, and runs an atomic Helm upgrade.
- The Helm Deployment has separate startup, readiness, and liveness probes against the Go health endpoints.

## First-time setup

1. Install Terraform, AWS CLI, Docker, kubectl, and Helm. Authenticate to AWS locally with an IAM identity permitted to create the bootstrap resources.
2. Set `AWS_REGION`, `STATE_BUCKET`, and `LOCK_TABLE`, then run `./scripts/bootstrap-state.sh`.
3. Copy `infra/backend.hcl.example` to `infra/backend.hcl` and fill in the generated bucket and table names.
4. Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and set the GitHub owner/repository and a restricted API CIDR when possible.
5. Run `terraform -chdir=infra init -backend-config=backend.hcl`, `terraform -chdir=infra plan`, and `terraform -chdir=infra apply`.

The Terraform outputs include the ECR repository URL, EKS cluster name, and GitHub Actions role ARN. Add these as GitHub Actions repository variables named `AWS_REGION`, `AWS_GITHUB_ACTIONS_ROLE_ARN`, `ECR_REPOSITORY`, and `EKS_CLUSTER_NAME`. Also add `TF_STATE_BUCKET` and `TF_LOCK_TABLE` for the infrastructure workflow.

For GitHub-hosted runners, the Kubernetes API endpoint is public but IAM-authenticated. Set `cluster_endpoint_public_access_cidrs` to the egress CIDRs of a self-hosted runner for a tighter production boundary.

## Local checks

```bash
go test ./app/...
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
helm lint k8s/helm/app
docker build -t eks-demo:local app
```

Destroy the environment with `terraform -chdir=infra destroy` after removing any load balancers. The state bucket and lock table are separate bootstrap resources and are not destroyed by the cluster stack.

## Other Cloud Providers

This repository also includes infrastructure for other cloud providers:

- **GCP GKE**: See [README-gcp.md](README-gcp.md)

All workflows are designed to run **manually** via GitHub Actions (workflow_dispatch) or automatically on push. They will fail if required repository variables are not set.

## Manual Workflow Execution

To run workflows manually:

1. Go to your repository on GitHub
2. Navigate to **Actions** tab
3. Select the workflow (e.g., "Terraform GCP")
4. Click **Run workflow**
5. Select the branch and configure inputs
6. Click **Run workflow**

Workflows will fail if required variables are not set in your repository settings (**Settings > Secrets and variables > Actions > Variables**).

## HCP Terraform Setup

This workspace uses **HCP Terraform** (`keyless-eks-infra-gcp`) as the remote backend for state management.

See [HCP_TERRAFORM_SETUP.md](HCP_TERRAFORM_SETUP.md) for full setup instructions.
