#!/bin/bash
# Complete setup script for GCP GKE infrastructure
# Usage: ./scripts/setup-all.sh

set -e

echo "=========================================="
echo "GCP GKE Infrastructure - Complete Setup"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check gcloud
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI not found${NC}"
    echo "   Install: https://cloud.google.com/sdk/docs/install"
    exit 1
else
    echo -e "${GREEN}✓ gcloud CLI found${NC}"
fi

# Check gsutil
if ! command -v gsutil &> /dev/null; then
    echo -e "${RED}❌ gsutil not found${NC}"
    echo "   Install: https://cloud.google.com/sdk/docs/install"
    exit 1
else
    echo -e "${GREEN}✓ gsutil found${NC}"
fi

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI not found${NC}"
    echo "   Install: https://cli.github.com/"
    echo "   You'll need to set variables manually in GitHub UI"
    USE_GH_CLI=false
else
    echo -e "${GREEN}✓ GitHub CLI found${NC}"
    USE_GH_CLI=true
fi

echo ""

# Step 1: Project setup
echo "=========================================="
echo "Step 1: GCP Project Setup"
echo "=========================================="
echo ""

CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -z "$CURRENT_PROJECT" ]; then
    echo -e "${YELLOW}No GCP project configured${NC}"
    read -p "Enter project ID to create/use (e.g., keyless-eks-demo): " PROJECT_ID
    if [ -z "$PROJECT_ID" ]; then
        echo -e "${RED}Project ID is required${NC}"
        exit 1
    fi
    
    echo ""
    echo "Creating GCP project: $PROJECT_ID"
    gcloud projects create "$PROJECT_ID" --name="Keyless EKS Demo"
    
    echo ""
    echo "Enabling billing (you'll need to do this in console)"
    echo "https://console.cloud.google.com/billing/links?project=$PROJECT_ID"
    read -p "Press Enter once billing is enabled..."
    
    gcloud config set project "$PROJECT_ID"
else
    echo "Using existing project: $CURRENT_PROJECT"
    echo "Enter 'n' to use a different project, or just press Enter to use this one:"
    read -p "> " USE_CURRENT
    if [ "$USE_CURRENT" = "n" ] || [ "$USE_CURRENT" = "N" ]; then
        read -p "Enter project ID to create: " PROJECT_ID_INPUT
        PROJECT_ID="$PROJECT_ID_INPUT"
        
        # Check if project exists, create if not
        if ! gcloud projects describe "$PROJECT_ID" &> /dev/null; then
            echo "Creating project: $PROJECT_ID"
            gcloud projects create "$PROJECT_ID" --name="Keyless EKS Demo"
        fi
        
        gcloud config set project "$PROJECT_ID"
    else
        PROJECT_ID="$CURRENT_PROJECT"
    fi
fi

echo ""
echo -e "${GREEN}✓ Project: $PROJECT_ID${NC}"

# Step 2: Enable APIs
echo ""
echo "=========================================="
echo "Step 2: Enable Required APIs"
echo "=========================================="
echo ""

echo -e "${YELLOW}⚠️  API enabling requires admin permissions${NC}"
echo ""
echo "Click this link to enable all required APIs:"
echo "https://console.cloud.google.com/flows/enableapi?project=$PROJECT_ID"
echo ""
echo "Or run in terminal (if you have permissions):"
echo "  gcloud services enable storage.googleapis.com container.googleapis.com artifactregistry.googleapis.com iam.googleapis.com iamcredentials.googleapis.com compute.googleapis.com"
echo ""
echo "Required APIs:"
echo "  - Cloud Storage API (storage.googleapis.com)"
echo "  - Kubernetes Engine API (container.googleapis.com)"
echo "  - Artifact Registry API (artifactregistry.googleapis.com)"
echo "  - IAM API (iam.googleapis.com)"
echo "  - IAM Credentials API (iamcredentials.googleapis.com)"
echo "  - Compute Engine API (compute.googleapis.com)"
echo ""

read -p "Continue anyway? APIs may need to be enabled before terraform will work. (Y/n): " CONTINUE
if [ "$CONTINUE" = "n" ] || [ "$CONTINUE" = "N" ]; then
    echo "Exiting. Please enable APIs and run again."
    exit 1
fi

echo -e "${GREEN}✓ Skipping API enabling (do it manually in console)${NC}"

# Step 3: Create Terraform state bucket (optional - only if not using Terraform Cloud)
echo ""
echo "=========================================="
echo "Step 3: Terraform State Configuration"
echo "=========================================="
echo ""

echo -e "${YELLOW}⚠️  Using HCP Terraform as backend - GCS bucket not required${NC}"
echo ""

# Create backend.hcl (empty - Terraform Cloud handles it)
cat > infra-gcp/backend.hcl << EOF
# Backend configuration - HCP Terraform remote backend
# State is managed by Terraform Cloud workspace: keyless-eks-infra-gcp

terraform {
  backend "http" {}
}
EOF

echo -e "${GREEN}✓ Created infra-gcp/backend.hcl (HCP Terraform backend)${NC}"
echo ""
echo "Note: Terraform Cloud will manage state automatically."
echo "No GCS bucket needed for this setup."

# Step 4: Setup GitHub Actions
echo ""
echo "=========================================="
echo "Step 4: GitHub Actions Setup"
echo "=========================================="
echo ""

REPO_INFO=$(git remote get-url origin 2>/dev/null | sed 's/.*://;s/\.git$//' | sed 's/.*\///')
GITHUB_OWNER=$(echo "$REPO_INFO" | cut -d'/' -f1)
REPO_NAME=$(echo "$REPO_INFO" | cut -d'/' -f2)

if [ -z "$GITHUB_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo -e "${YELLOW}Could not detect GitHub repo${NC}"
    read -p "Enter GitHub organization: " GITHUB_OWNER
    read -p "Enter repository name: " REPO_NAME
fi

echo "Detected: $GITHUB_OWNER/$REPO_NAME"
echo ""

# Get Terraform Cloud org
TFC_WORKSPACE="keyless-eks-infra-gcp"
TFC_ORGANIZATION=$(echo "$TFC_WORKSPACE" | sed 's/-infra-gcp$//')
echo "Suggested TFC_ORGANIZATION: $TFC_ORGANIZATION"
read -p "Enter TFC_ORGANIZATION (default: $TFC_ORGANIZATION): " TFC_ORG_INPUT
TFC_ORGANIZATION="${TFC_ORG_INPUT:-$TFC_ORGANIZATION}"

echo ""
echo -e "${YELLOW}=== Copy these values to GitHub ===${NC}"
echo ""
echo "Variables (Settings → Secrets and variables → Actions → Variables):"
echo "  TFC_ORGANIZATION       = $TFC_ORGANIZATION"
echo "  TFC_WORKSPACE          = $TFC_WORKSPACE"
echo "  GCP_PROJECT_ID         = $PROJECT_ID"
echo "  TF_STATE_BUCKET        = $BUCKET_NAME"
echo "  GCP_WORKLOAD_IDENTITY_PROVIDER = [SET AFTER TERRAFORM APPLY]"
echo "  GCP_SERVICE_ACCOUNT    = [SET AFTER TERRAFORM APPLY]"
echo "  GITHUB_OWNER           = $GITHUB_OWNER"
echo "  GITHUB_REPOSITORY      = $REPO_NAME"
echo ""
echo "Secrets (Settings → Secrets and variables → Actions → Secrets):"
echo "  TFC_TOKEN              = [Your Terraform Cloud API token]"
echo ""

if [ "$USE_GH_CLI" = true ]; then
    read -p "Set variables via gh CLI? (y/N): " SET_VARS
    if [ "$SET_VARS" = "y" ] || [ "$SET_VARS" = "Y" ]; then
        if ! gh auth status > /dev/null 2>&1; then
            echo "Logging in to GitHub..."
            gh auth login
        fi
        
        gh variable set TFC_ORGANIZATION --body "$TFC_ORGANIZATION"
        gh variable set TFC_WORKSPACE --body "$TFC_WORKSPACE"
        gh variable set GCP_PROJECT_ID --body "$PROJECT_ID"
        if [ -n "$BUCKET_NAME" ]; then
            gh variable set TF_STATE_BUCKET --body "$BUCKET_NAME"
        fi
        gh variable set GITHUB_OWNER --body "$GITHUB_OWNER"
        gh variable set GITHUB_REPOSITORY --body "$REPO_NAME"
        
        echo -e "${GREEN}✓ Variables set via gh CLI${NC}"
        echo ""
        echo "Remember to set TFC_TOKEN secret:"
        echo "  gh secret set TFC_TOKEN --body [YOUR_TOKEN]"
    else
        echo -e "${YELLOW}Set variables manually in GitHub UI${NC}"
    fi
else
    echo -e "${YELLOW}Install gh CLI to automate this step${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Set Terraform Cloud API token:"
echo "   gh secret set TFC_TOKEN --body [YOUR_TOKEN]"
echo ""
echo "2. Initialize Terraform:"
echo "   cd infra-gcp"
echo "   terraform init -backend-config=backend.hcl"
echo ""
echo "3. Review configuration:"
echo "   terraform plan"
echo ""
echo "4. Apply infrastructure:"
echo "   terraform apply"
echo ""
echo "5. After apply, update GCP variables in GitHub:"
echo "   - GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "   - GCP_SERVICE_ACCOUNT"
echo ""
