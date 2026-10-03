#!/bin/bash
# Script to setup GCP Terraform state bucket
# Usage: ./scripts/setup-gcp-state.sh [PROJECT_ID] [BUCKET_NAME]

set -e

echo "=========================================="
echo "GCP Terraform State Setup"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${YELLOW}gcloud CLI not found. Please install it first:${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo -e "${YELLOW}gsutil not found. Please install it via gcloud SDK:${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get project ID
if [ -z "$1" ]; then
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$CURRENT_PROJECT" ]; then
        echo -e "${YELLOW}No GCP project configured. Please run:${NC}"
        echo "  gcloud config set project YOUR_PROJECT_ID"
        echo ""
        read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
    else
        echo "Detected current project: $CURRENT_PROJECT"
        read -p "Use this project? (Y/n): " USE_CURRENT
        if [ "$USE_CURRENT" = "n" ] || [ "$USE_CURRENT" = "N" ]; then
            read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
        else
            GCP_PROJECT_ID="$CURRENT_PROJECT"
        fi
    fi
else
    GCP_PROJECT_ID="$1"
fi

# Get bucket name
DEFAULT_BUCKET="tfstate-${GCP_PROJECT_ID}"
if [ -z "$2" ]; then
    read -p "Enter bucket name (default: ${DEFAULT_BUCKET}): " BUCKET_NAME
    BUCKET_NAME="${BUCKET_NAME:-$DEFAULT_BUCKET}"
else
    BUCKET_NAME="$2"
fi

echo ""
echo "=========================================="
echo "Configuration"
echo "=========================================="
echo "GCP Project ID: $GCP_PROJECT_ID"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: us-central1"
echo ""

# Ask to proceed
read -p "Proceed with setup? (y/N): " PROCEED
if [ "$PROCEED" != "y" ] && [ "$PROCEED" != "Y" ]; then
    echo "Setup cancelled."
    exit 0
fi

# Enable required APIs
echo ""
echo "Enabling Cloud Storage API..."
gcloud services enable storage.googleapis.com --project="$GCP_PROJECT_ID"

# Create bucket
echo ""
echo "Creating Cloud Storage bucket..."
if gsutil ls gs://$BUCKET_NAME &> /dev/null; then
    echo -e "${GREEN}✓ Bucket $BUCKET_NAME already exists${NC}"
else
    gsutil mb -p "$GCP_PROJECT_ID" -l us-central1 gs://$BUCKET_NAME/
    echo -e "${GREEN}✓ Created bucket: gs://$BUCKET_NAME/${NC}"
fi

# Enable versioning
echo ""
echo "Enabling versioning..."
gsutil versioning set on gs://$BUCKET_NAME/
echo -e "${GREEN}✓ Versioning enabled${NC}"

# Enable encryption (optional but recommended)
echo ""
echo "Enabling default encryption..."
gsutil encryption set -c gs://$BUCKET_NAME/
echo -e "${GREEN}✓ Default encryption enabled${NC}"

# Create backend configuration file
echo ""
echo "Creating backend.hcl configuration..."
cat > infra-gcp/backend.hcl << EOF
bucket         = "$BUCKET_NAME"
prefix         = "keyless-eks/terraform.tfstate"
project        = "$GCP_PROJECT_ID"
region         = "us-central1"
encrypt        = true
EOF

echo -e "${GREEN}✓ Created infra-gcp/backend.hcl${NC}"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Update infra-gcp/terraform.tfvars with your values:"
echo "   - gcp_project_id = $GCP_PROJECT_ID"
echo "   - github_owner = your-github-org"
echo "   - github_repository = your-repository"
echo ""
echo "2. Initialize Terraform:"
echo "   cd infra-gcp"
echo "   terraform init -backend-config=backend.hcl"
echo ""
echo "3. Run terraform plan and apply:"
echo "   terraform plan"
echo "   terraform apply"
echo ""
