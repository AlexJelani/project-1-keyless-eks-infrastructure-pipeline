# Enable Required GCP APIs

Go to this URL to enable all required APIs for your project:

```
https://console.cloud.google.com/flows/enableapi?project=keyless-eks-devsecops&apiids=artifactregistry.googleapis.com,compute.googleapis.com,container.googleapis.com,iam.googleapis.com,iamcredentials.googleapis.com,storage.googleapis.com
```

Or manually enable each API:

1. Go to [console.cloud.google.com/apis/library](https://console.cloud.google.com/apis/library)
2. Select project: `keyless-eks-devsecops`
3. Search and enable each API:
   - Artifact Registry API
   - Compute Engine API
   - Kubernetes Engine API
   - IAM API
   - IAM Credentials API
   - Cloud Storage API