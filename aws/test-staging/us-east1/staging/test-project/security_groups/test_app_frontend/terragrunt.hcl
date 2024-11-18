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

dependency "sg_alb" {
  config_path = "../alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-0417d4404d84892fa"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}


inputs = {
  vpc_id                     = dependency.vpc.outputs.vpc_id
  security_groups_in_service = dependency.sg_alb.outputs.security_group_id

  name                     = "${local.locals.project_name}-frontend-app-ecs-sg"
  description              = "Security group for service with HTTP ports open for ALB"
  use_name_prefix          = false
  ingress_with_cidr_blocks = []
  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Security Groups for inbound traffic to service"
      source_security_group_id = dependency.sg_alb.outputs.security_group_id
    }
  ]
  egress_with_source_security_group_id = []

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_id}"
  }
}