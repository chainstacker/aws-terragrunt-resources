include {
  path = find_in_parent_folders()
}

include "rds" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_rds.hcl"
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
    local.project_localss,
    local.env_locals,
    local.module_locals
  )
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-012341a0dd8b01234"
    public_subnets = [
      "subnet-003601fe683fd1111",
      "subnet-0f0787cffc6ae1112",
      "subnet-00e05034aa90b1112"
    ],
  }
}

dependency "sg_rds" {
  config_path                             = "../security_groups/rds_postgresql"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-02092eea015a2eade"
  }
}

inputs = {
  identifier                  = "test-app-instance"
  vpc_id                      = dependency.vpc.outputs.vpc_id
  engine                      = "postgres"
  engine_version              = "16.3"
  instance_class              = "db.m5.large"
  family                      = "postgres16"
  allocated_storage           = 20
  username                    = "postgres"
  parameter_group_name        = "postgres16"
  vpc_security_group_ids      = [dependency.sg_rds.outputs.security_group_id]
  create_db_subnet_group      = true
  subnet_ids                  = dependency.vpc.outputs.public_subnets
  skip_final_snapshot         = false
  publicly_accessible         = true
  backup_retention_period     = 30
  multi_az                    = true
  storage_type                = "gp2"

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_id}"
  }
}
