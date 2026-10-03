# Implementation Plan: Migrate EKS Infrastructure to GCP GKE

## Overview
This plan migrates the AWS EKS infrastructure to GCP GKE, maintaining the same application deployment architecture while adapting to GCP's native services (Workload Identity Federation, Artifact Registry, Cloud NAT, etc.).

## Prerequisites
- Terraform >= 1.3.0
- GCP project with billing enabled
- GitHub Actions repository variables to be configured after deployment
- Enable GCP APIs: `container.googleapis.com`, `artifactregistry.googleapis.com`, `iam.googleapis.com`, `iamcredentials.googleapis.com`

## Decision Log

**Decision 1: GCP Region Selection**
- Chose `us-central1` as default region for broad availability and cost-effectiveness
- Rationale: Consistent with GCP best practices for general-purpose workloads

**Decision 2: Node Pool Configuration**
- Will use SPOT (preemptible) instances for the default node pool to reduce cost
- Rationale: Matches the original AWS design intent for cost optimization

**Decision 3: Network Topology**
- Will use GCP Custom VPC mode with 3 subnets across 3 zones (us-central1-a/b/c)
- Cloud NAT for each zone instead of NAT gateways
- Rationale: Equivalent to AWS multi-AZ private subnet design

**Decision 4: Workload Identity Federation**
- Will implement WIF with GitHub Actions OIDC provider
- Service account binding conditioned on `repository` and `ref` claims
- Rationale: GCP's equivalent to AWS OIDC integration for GitHub Actions

**Decision 5: Artifact Registry**
- Will use Artifact Registry in Docker format with regional scope
- URL format: `${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}`
- Rationale: Native GCP container registry equivalent to ECR

**Decision 6: State Backend**
- Will use GCS bucket instead of S3
- Rationale: GCP native, versioned bucket storage

**Decision 7: Helm Chart Compatibility**
- Will NOT modify `k8s/helm/app/` - it's already cloud-agnostic
- Rationale: Kubernetes manifests are infrastructure-agnostic

## Implementation Steps

- [ ] 1. Create infra-gcp directory structure and root files
      Create providers.tf, backend.tf, variables.tf, main.tf, outputs.tf with all GCP configurations
      Files: infra-gcp/providers.tf, infra-gcp/backend.tf, infra-gcp/variables.tf, infra-gcp/main.tf, infra-gcp/outputs.tf
      Verify: `terraform -chdir=infra-gcp fmt -check -recursive && terraform -chdir=infra-gcp validate` — no errors

- [ ] 2. Create VPC module for GCP
      VPC in custom mode, 3 subnetworks (us-central1-a/b/c), Cloud Router, Cloud NAT per zone
      Files: infra-gcp/modules/vpc/main.tf, infra-gcp/modules/vpc/variables.tf, infra-gcp/modules/vpc/outputs.tf
      Verify: `terraform -chdir=infra-gcp/modules/vpc fmt -check -recursive && terraform -chdir=infra-gcp/modules/vpc validate` — no errors

- [ ] 3. Create GKE module for GCP
      Private cluster with master_ipv4_cidr_block, Workload Identity enabled, logging to Cloud Operations, public endpoint with 0.0.0.0/0 access, preemptible node pool
      Files: infra-gcp/modules/gke/main.tf, infra-gcp/modules/gke/variables.tf, infra-gcp/modules/gke/outputs.tf
      Verify: `terraform -chdir=infra-gcp/modules/gke fmt -check -recursive && terraform -chdir=infra-gcp/modules/gke validate` — no errors

- [ ] 4. Create Artifact Registry module
      Docker repository in regional scope
      Files: infra-gcp/modules/artifact-registry/main.tf, infra-gcp/modules/artifact-registry/variables.tf, infra-gcp/modules/artifact-registry/outputs.tf
      Verify: `terraform -chdir=infra-gcp/modules/artifact-registry fmt -check -recursive && terraform -chdir=infra-gcp/modules/artifact-registry validate` — no errors

- [ ] 5. Create IAM module with Workload Identity Federation
      WIF pool + OIDC provider for GitHub Actions (issuer https://token.actions.githubusercontent.com), Service Account with container.developer and artifactregistry.writer roles, binding conditioned on repo/branch sub claims
      Files: infra-gcp/modules/iam/main.tf, infra-gcp/modules/iam/variables.tf, infra-gcp/modules/iam/outputs.tf
      Verify: `terraform -chdir=infra-gcp/modules/iam fmt -check -recursive && terraform -chdir=infra-gcp/modules/iam validate` — no errors

- [ ] 6. Create example configuration files
      backend.hcl.example and terraform.tfvars.example for infra-gcp
      Files: infra-gcp/backend.hcl.example, infra-gcp/terraform.tfvars.example
      Verify: Files exist with correct placeholder values

- [ ] 7. Update GitHub Actions workflow for Terraform
      Create terraform-gcp.yml with google-github-actions/auth@v2 and -backend-config for GCS
      Files: .github/workflows/terraform-gcp.yml
      Verify: Workflow syntax valid — `curl -sSL https://github.com/rtCamp/action-yaml-validator/releases/latest/download/action-validator -o action-validator && chmod +x action-validator && ./action-validator .github/workflows/terraform-gcp.yml`

- [ ] 8. Update GitHub Actions workflow for deployment
      Create deploy-gcp.yml with auth, Artifact Registry login, get-gke-credentials, and helm upgrade to AR URL
      Files: .github/workflows/deploy-gcp.yml
      Verify: Workflow syntax valid (same validator as step 7)

- [ ] 9. Create README-gcp.md documentation
      Cover prerequisites, GCP setup, API enabling, bootstrap commands, GitHub Actions variables, cost estimate section, ASCII architecture diagram
      Files: README-gcp.md
      Verify: Documentation complete and readable

## Verification Commands

All Terraform validation:
```bash
terraform -chdir=infra-gcp fmt -check -recursive
terraform -chdir=infra-gcp validate
```

Helm chart validation (unchanged):
```bash
helm lint k8s/helm/app
```

Workflow syntax validation:
```bash
action-validator .github/workflows/terraform-gcp.yml
action-validator .github/workflows/deploy-gcp.yml
```

## Files Created

```
infra-gcp/
├── providers.tf
├── backend.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── backend.hcl.example
├── terraform.tfvars.example
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── gke/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── artifact-registry/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
.github/workflows/
├── terraform-gcp.yml
└── deploy-gcp.yml
README-gcp.md
```

## Key Differences from AWS

| AWS | GCP |
|-----|-----|
| S3 + DynamoDB (backend) | GCS (backend) |
| EKS | GKE |
| ECR | Artifact Registry |
| IAM OIDC provider | Workload Identity Federation |
| NAT Gateway (per AZ) | Cloud NAT (per zone) |
| managed node groups | GKE node pool with preemptible nodes |
| AWS EKS access entries | Kubernetes RBAC + IAM bindings |
| `sts.amazonaws.com` OIDC audience | `https://token.actions.githubusercontent.com` |

## Cost Estimate Comparison (approximate, us-central1)

| Resource | AWS (ap-northeast-1) | GCP (us-central1) |
|----------|----------------------|-------------------|
| Control Plane | $73/mo (EKS) | Free (GKE) |
| Nodes (3x t3.medium) | ~$150/mo | ~$117/mo (e2-medium preemptible) |
| VPC NAT Gateway (3) | ~$45/mo | Free (Cloud NAT included) |
| ECR | ~$2/mo | ~$0.10/mo (Artifact Registry) |
| S3 State Backend | ~$0.50/mo | Free (GCS standard storage) |
| **Total (approx)** | ~$270/mo | ~$117/mo |

**Estimated savings: ~57% with GCP GKE** due to free control plane and preemptible nodes.

## Notes

- Existing `infra/` and `infra/modules/` directories MUST NOT be modified
- Existing `.github/workflows/terraform.yml` and `.github/workflows/deploy.yml` MUST NOT be modified
- Helm chart in `k8s/helm/app/` requires no changes — it's cloud-agnostic
- GKE's managed control plane is free (unlike EKS which charges $73/mo)
- SPOT/preemptible nodes reduce node costs by ~60% but may be evicted (acceptable for stateless workloads)