# HCP Terraform Setup Guide

This guide shows you how to configure your workspace for both GCP and Azure infrastructure.

## Step 1: Create Terraform Cloud Tokens

1. Go to [app.terraform.io](https://app.terraform.io)
2. Click your profile → **User settings → Tokens**
3. Click **Generate an API Token**
4. Copy the token (you'll need it for GitHub secrets)

## Step 2: Add GitHub Secrets and Variables

Go to your GitHub repository → **Settings → Secrets and variables → Actions**

### Secrets:
| Secret | Description |
|--------|-------------|
| `TFC_TOKEN` | Your Terraform Cloud API token |

### Variables:
| Variable | Description |
|----------|-------------|
| `TFC_ORGANIZATION` | Your Terraform Cloud organization name |
| `TFC_WORKSPACE` | `keyless-eks-infra` (your workspace name) |

## Step 3: Set Terraform Variables in Workspace

Go to your workspace → **Variables tab** and add:

### GCP Variables:
| Variable | Type | Description |
|----------|------|-------------|
| `gcp_project_id` | Environment | Your GCP Project ID |
| `github_owner` | Environment | Your GitHub organization |
| `github_repository` | Environment | Your repository name |

### Azure Variables:
| Variable | Type | Description |
|----------|------|-------------|
| `azure_subscription_id` | Environment | Your Azure Subscription ID |
| `azure_tenant_id` | Environment | Your Azure Tenant ID |

## Step 4: Choose Your Setup

### Option A: One Workspace (Recommended for Demo)

The workspace `keyless-eks-infra` will handle both GCP and Azure.

Run workflows manually:
1. Go to **Actions tab**
2. Select **"Terraform GCP"** or **"Terraform Azure"**
3. Click **Run workflow**

### Option B: Separate Workspaces

Create separate workspaces:
- `keyless-eks-gcp` for GCP
- `keyless-eks-azure` for Azure

Update the `TFC_WORKSPACE` variable in GitHub accordingly.

## Step 5: Run Your First Plan

1. Click **"Start your first plan"** in the workspace
2. Or run the workflow manually via GitHub Actions

## Troubleshooting

**Error: "workspace not found"**
- Check `TFC_WORKSPACE` variable matches your workspace name exactly

**Error: "organization not found"**
- Check `TFC_ORGANIZATION` matches your Terraform Cloud organization name

**Error: "invalid token"**
- Regenerate your API token in Terraform Cloud and update `TFC_TOKEN`
