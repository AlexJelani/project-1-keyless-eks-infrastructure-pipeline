#!/bin/bash
# Script to setup GitHub Actions variables for GCP GKE infrastructure
# Usage: ./scripts/setup-github-actions.sh

set -e

echo "=========================================="
echo "GCP GKE GitHub Actions Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI (gh) not found. Please install it first:${NC}"
    echo "https://cli.github.com/"
    echo "Or skip this script and set variables manually in GitHub UI."
    echo ""
    echo "Required variables to set manually:"
    echo "- TFC_ORGANIZATION: Your Terraform Cloud organization"
    echo "- TFC_TOKEN: Your Terraform Cloud API token"
    echo "- GCP_PROJECT_ID: Your GCP Project ID"
    echo "- TF_STATE_BUCKET: Your GCS bucket name"
    echo "- GCP_WORKLOAD_IDENTITY_PROVIDER: Your WIF pool provider"
    echo "- GCP_SERVICE_ACCOUNT: Your service account email"
    echo "- GITHUB_OWNER: Your GitHub organization"
    echo "- GITHUB_REPOSITORY: Your repository name"
    exit 0
fi

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Get GitHub repo info
REPO_NAME=$(basename "$(git config --get remote.origin.url .git 2>/dev/null | sed 's/.*://;s/\.git$//')")
GITHUB_OWNER=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*://;s/\.git$//' | sed 's/.*\///')

if [ -z "$REPO_NAME" ] || [ -z "$GITHUB_OWNER" ]; then
    echo -e "${YELLOW}Could not auto-detect GitHub repository. Please set manually.${NC}"
    echo ""
fi

echo "Detected repository: $GITHUB_OWNER/$REPO_NAME"
echo ""

# Get Terraform Cloud organization from workspace name
TFC_WORKSPACE="keyless-eks-infra-gcp"
echo "Terraform Cloud workspace: $TFC_WORKSPACE"
TFC_ORGANIZATION=$(echo "$TFC_WORKSPACE" | sed 's/-infra-gcp$//')
echo "Suggested TFC_ORGANIZATION: $TFC_ORGANIZATION"
echo ""

# Prompt for variables
echo "Enter the following values (press Enter to skip auto-detection):"

read -p "TFC_ORGANIZATION (default: $TFC_ORGANIZATION): " TFC_ORG_INPUT
TFC_ORGANIZATION="${TFC_ORG_INPUT:-$TFC_ORGANIZATION}"

read -p "GCP_PROJECT_ID: " GCP_PROJECT_ID
read -p "TF_STATE_BUCKET: " TF_STATE_BUCKET

# Construct WIF provider
read -p "WIF_POOL_ID (e.g., projects/123456/locations/global/workloadIdentityPools/github-dev): " WIF_POOL_ID
GCP_WORKLOAD_IDENTITY_PROVIDER="${WIF_POOL_ID}/providers/github-dev"

read -p "GCP_SERVICE_ACCOUNT_EMAIL: " GCP_SERVICE_ACCOUNT

# Set defaults for GitHub
GITHUB_OWNER="${GITHUB_OWNER:-your-github-org}"
read -p "GITHUB_OWNER (default: $GITHUB_OWNER): " GITHUB_OWNER_INPUT
GITHUB_OWNER="${GITHUB_OWNER_INPUT:-$GITHUB_OWNER}"

REPO_NAME="${REPO_NAME:-your-repository}"
read -p "GITHUB_REPOSITORY (default: $REPO_NAME): " REPO_NAME_INPUT
REPO_NAME="${REPO_NAME_INPUT:-$REPO_NAME}"

echo ""
echo "=========================================="
echo "Summary - Variables to set in GitHub"
echo "=========================================="
echo ""
echo "Repository Variables (Settings → Secrets and variables → Actions → Variables):"
echo "  TFC_ORGANIZATION       = $TFC_ORGANIZATION"
echo "  TFC_WORKSPACE          = $TFC_WORKSPACE"
echo "  GCP_PROJECT_ID         = $GCP_PROJECT_ID"
echo "  TF_STATE_BUCKET        = $TF_STATE_BUCKET"
echo "  GCP_WORKLOAD_IDENTITY_PROVIDER = $GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "  GCP_SERVICE_ACCOUNT    = $GCP_SERVICE_ACCOUNT"
echo "  GITHUB_OWNER           = $GITHUB_OWNER"
echo "  GITHUB_REPOSITORY      = $REPO_NAME"
echo ""
echo "Repository Secrets (Settings → Secrets and variables → Actions → Secrets):"
echo "  TFC_TOKEN              = [Your Terraform Cloud API token]"
echo ""

# Create env file for reference
cat > "$REPO_DIR/.env.github" << EOF
# GitHub Actions variables for GCP GKE infrastructure
TFC_ORGANIZATION=$TFC_ORGANIZATION
TFC_WORKSPACE=$TFC_WORKSPACE
GCP_PROJECT_ID=$GCP_PROJECT_ID
TF_STATE_BUCKET=$TF_STATE_BUCKET
GCP_WORKLOAD_IDENTITY_PROVIDER=$GCP_WORKLOAD_IDENTITY_PROVIDER
GCP_SERVICE_ACCOUNT=$GCP_SERVICE_ACCOUNT
GITHUB_OWNER=$GITHUB_OWNER
GITHUB_REPOSITORY=$REPO_NAME
EOF

echo -e "${GREEN}✓ Created .env.github file with values for reference${NC}"
echo ""

# Ask if user wants to set variables via gh CLI
read -p "Do you want to try to set these variables using gh CLI? (y/N): " SET_VARS
if [ "$SET_VARS" = "y" ] || [ "$SET_VARS" = "Y" ]; then
    echo ""
    echo "Setting variables via gh CLI..."
    
    # Login to GitHub
    if ! gh auth status > /dev/null 2>&1; then
        echo "Logging in to GitHub..."
        gh auth login
    fi
    
    # Set variables
    gh variable set TFC_ORGANIZATION --body "$TFC_ORGANIZATION"
    gh variable set TFC_WORKSPACE --body "$TFC_WORKSPACE"
    gh variable set GCP_PROJECT_ID --body "$GCP_PROJECT_ID"
    gh variable set TF_STATE_BUCKET --body "$TF_STATE_BUCKET"
    gh variable set GCP_WORKLOAD_IDENTITY_PROVIDER --body "$GCP_WORKLOAD_IDENTITY_PROVIDER"
    gh variable set GCP_SERVICE_ACCOUNT --body "$GCP_SERVICE_ACCOUNT"
    gh variable set GITHUB_OWNER --body "$GITHUB_OWNER"
    gh variable set GITHUB_REPOSITORY --body "$REPO_NAME"
    
    echo ""
    echo -e "${GREEN}✓ Variables set successfully!${NC}"
    echo ""
    echo "Now set the TFC_TOKEN secret:"
    echo "  gh secret set TFC_TOKEN --body [YOUR_TOKEN]"
else
    echo ""
    echo -e "${YELLOW}To set variables manually in GitHub UI:${NC}"
    echo "  1. Go to your repository on GitHub"
    echo "  2. Navigate to Settings → Secrets and variables → Actions"
    echo "  3. Click 'New repository variable' and add each variable above"
    echo "  4. For TFC_TOKEN, click 'New secret' instead"
fi

echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo "1. Set TFC_TOKEN secret:"
echo "   gh secret set TFC_TOKEN --body [YOUR_TOKEN]"
echo ""
echo "2. Run Terraform to provision infrastructure:"
echo "   cd infra-gcp"
echo "   terraform init -backend-config=backend.hcl"
echo "   terraform apply"
echo ""
echo "3. The terraform apply outputs will contain GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "   and GCP_SERVICE_ACCOUNT values. Update these in GitHub after apply."
echo ""
