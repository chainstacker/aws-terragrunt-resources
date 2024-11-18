include {
  path = find_in_parent_folders()
}

include "security_groups" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_security-groups.hcl"
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
  config_path = "../../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-04e3e1e302f8c8f06"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id
  name            = "${local.locals.project_name}-app-alb-sg"
  description     = "Security group for service with HTTP ports open for ALB"
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Service ports (ipv4). All"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Service ports (ipv4). All"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_with_source_security_group_id = []
  egress_with_source_security_group_id  = []

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_id}"
  }
}

