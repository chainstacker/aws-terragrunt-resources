include {
  path = find_in_parent_folders()
}

include "ecr" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_ecr.hcl"
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
  repository_name                 = "p2p_images_repository"
  repository_image_tag_mutability = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Remove not latest image",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 100
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_code}"
  }
}
