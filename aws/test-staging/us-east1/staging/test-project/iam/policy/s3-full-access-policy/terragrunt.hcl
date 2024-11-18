include {
  path = find_in_parent_folders()
}

include "iam" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_iam-policy.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_locals  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  env_locals     = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  project_locals = read_terragrunt_config(find_in_parent_folders("project.hcl")).locals
  module_locals  = try(read_terragrunt_config("module.hcl").locals, {})
  locals = merge(
    local.account_locals,
    local.region_locals,
    local.project_locals,
    local.env_locals,
    local.module_locals
  )
}

inputs = {
  name        = "${local.locals.project_name}-bucket-s3-full-access"
  path        = "/"
  description = "IAM policy for full access to the ${local.locals.project_name}-milvus-bucket bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MilvusBucketBucketFullAccess"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::test-apps-backup-bucket",
          "arn:aws:s3:::test-apps-backup-bucket/*"
        ]
      }
    ]
  })
}