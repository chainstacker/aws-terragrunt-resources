include {
  path = find_in_parent_folders()
}

include "iam" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_iam-oidc-role.hcl"
}

inputs = {
  # Replace with your GitHub organization/repository details
  name = "test-github-oidc-role"
  subjects = ["repo:chainstackerorg/*"] #Add your organisation or repository name

  # Attach the S3 ReadOnly policy to the IAM role
    policies = {
        S3ReadOnly                            = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
        AmazonEC2ContainerRegistryPowerUser   = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
        AmazonEC2ContainerServiceRole         = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
        AmazonECS_FullAccess                  = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
        SecretsManagerReadWrite               = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    }

  # Optional audience (defaults to sts.amazonaws.com for GitHub Pro)
  audience = "sts.amazonaws.com"
}
