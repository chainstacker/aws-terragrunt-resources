locals {
  account_locals     = try(read_terragrunt_config("account.hcl").locals, read_terragrunt_config(find_in_parent_folders("account.hcl")).locals, {})
  project_locals     = try(read_terragrunt_config("project.hcl").locals, read_terragrunt_config(find_in_parent_folders("project.hcl")).locals, {})
  region_locals      = try(read_terragrunt_config("region.hcl").locals, read_terragrunt_config(find_in_parent_folders("region.hcl")).locals, {})
  environment_locals = try(read_terragrunt_config("environment.hcl").locals, read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals, {})
  module_locals      = try(read_terragrunt_config("module.hcl").locals, {})

  merged_locals = merge(
    local.account_locals,
    local.project_locals,
    local.region_locals,
    local.environment_locals,
    local.module_locals
  )

  module_version = try(
    local.merged_locals.module_terraform_aws_modules_alb_version,
    local.merged_locals.module_version,
    "8.7.0"
  )
}

terraform {
  source = "tfr:///terraform-aws-modules/alb/aws?version=${local.module_version}"
}

