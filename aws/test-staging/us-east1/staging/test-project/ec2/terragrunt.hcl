
include {
  path = find_in_parent_folders()
}

include "ec2_instance" {
    path = "${get_repo_root()}/modules/terraform-aws-modules_ec2-instance.hcl"
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
  mock_outputs = {
    vpc_id = "vpc-012341a0dd8b01234"
    public_subnets = [
      "subnet-003601fe683fd1111",
      "subnet-0f0787cffc6ae1112",
      "subnet-00e05034aa90b1112"
    ],
  }
}

dependency "sg_ec2" {
  config_path                             = "../../security_groups/ec2/test_app_vm_sg"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-02092eea015a2eade"
  }
}

inputs = {
  name                                = "${local.locals.project_name}-testing-instance"
  ami                                 = "ami-0e86e20dae9224db8"
  instance_type                       = "m5.xlarge"
  key_name                            = "test-app-key-pair"
  monitoring                          = true
  associate_public_ip_address = true
  vpc_security_group_ids              = [dependency.sg_ec2.outputs.security_group_id]
  subnet_id                           = dependency.vpc.outputs.public_subnets[0]  # Using the first public subnet in the list

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device = [{
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }]

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_id}"
  }
}