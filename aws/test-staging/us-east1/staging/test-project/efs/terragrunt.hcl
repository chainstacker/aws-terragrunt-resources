include {
  path = find_in_parent_folders()
}

include "efs" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_efs.hcl"
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

dependency "vpc" {
  config_path                             = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-08a452f3fd21ab9ee"
    public_subnets = [
      "subnet-061b1b230e42d87e1",
      "subnet-0528e06cf1720554b",
      "subnet-01ca1ccbe9a0fa088"
    ],
    private_subnets = [
      "subnet-029f60217aaf3aa78",
      "subnet-08b190497006ff653",
      "subnet-0469437551484a733",
    ],
  }
}


inputs = {
  name            = "${local.locals.project_name}-${local.locals.environment_name}-app-config"
  throughput_mode = "elastic"
  attach_policy   = false
  access_points = [
    {
      name = "reth"
      root_directory = {
        path = "/"
      }
    }
  ]
  security_group_vpc_id = dependency.vpc.outputs.vpc_id
  lifecycle_policy = {
    transition_to_ia      = "AFTER_30_DAYS"
    transition_to_archive = "AFTER_90_DAYS"
  }

  tags = {
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    Region      = "${local.locals.aws_region}"
    Owner       = "${local.locals.Owner}"
    ManagedBy   = "${local.locals.ManagedBy}"
    ProjectCode = "${local.locals.project_code}"

  }
}
