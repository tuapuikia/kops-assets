How to use the script?

1. Download the script from github.
2. chmod +x kops-assets.sh
3. ./kops-assets.sh <k8s version> <kops version>
    ./kops-assets.sh v1.15.12 1.21.0
4. aws s3 sync --acl public-read kops-assets s3://my-s3-bucket/kops-assets
