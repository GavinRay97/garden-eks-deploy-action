# Garden EKS Deploy Action

This Action:

- Downloads `kubectl`
- Uses the `garden-aws` container image to provide `garden` and `aws` CLI binaries
- Configures access to AWS through your access key and secret key
- Generates a `KUBECONFIG` for the desired cluster, and exports it to `PATH`

After doing this, you have the ability to interact with your cluster through `kubectl`, the AWS CLI, and `garden` like you would locally. You need to implement the final steps of navigating to the directory of your project containing the root `garden.yml` and run `garden deploy --env=your-aws-remote-name`

The required environment variables are:

- `AWS_REGION`
- `EKS_CLUSTER_NAME`
- `KUBECONFIG_CLUSTER_NAME` (see description below in example usage)

And the required secrets are:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

```yaml
name: Deploy

on:
  push:
    branches:
      - develop
      - 'release/**'

env:
  AWS_REGION: us-east-2
  EKS_CLUSTER_NAME: my-eks-cluster
  # The value for "context" variable in project-level "garden.yml" for AWS
  # This could be identical to EKS_CLUSTER_NAME, or different if your local KUBECONFIG has an alias,
  # such as when creating clusters with eksctl
  #
  # Example:
  #   - name: kubernetes
  #   environments: [aws]
  #   context: my-eks-cluster
  #
  # This is due to this line:
  # aws eks update-kubeconfig --region ${aws_region} --name ${cluster_name} --alias ${kubeconfig_cluster_name}
  # As EKS clusters come with default names like "arn:aws:eks:us-east-2:123098607654:cluster/my-cluster"
  # So you may have either aliased it in KUBECONFIG and your "garden.yml", or created with eksctl which gives different names
  KUBECONFIG_CLUSTER_NAME: my-eks-cluster

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        uses: garden-eks-deploy-action
        env:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: $AWS_REGION
          cluster_name: $EKS_CLUSTER_NAME
          kubeconfig_cluster_name: $KUBECONFIG_CLUSTER_NAME
        with:
          # CD to the location of your project-level "garden.yml", if it's not in root
          # Export KUBECONFIG
          # Run the deploy
          args: |
            cd app
            export KUBECONFIG=/github/home/.kube/config
            garden deploy --env=aws
```
