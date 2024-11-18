include {
  path = find_in_parent_folders()
}

include "autoscaling" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_autoscaling.hcl"
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
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-08a452f3fd21ab9ee"
  }
}

dependency "sg_alb" {
  config_path                             = "../security_groups/alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-012342a929807e708"
  }
}
inputs = {
  name                    = "${local.locals.project_name}-${local.locals.environment_name}-asg"
  use_name_prefix         = false
  instance_name           = "${local.locals.project_name}-${local.locals.environment_name}-lc-"
  capacity_rebalance      = false
  default_cooldown        = 300
  default_instance_warmup = 0
  service_linked_role_arn = "arn:aws:iam::599564732950:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  image_id                = "ami-0d6d367ace19e09dd"
  instance_type           = "m5.xlarge"
  key_name                = "ec2-ssh-key-1-test-app"
  launch_template_name    = "${local.locals.project_name}-dev-lc"
  default_version         = 1
  launch_template_version = "$Latest"
  block_device_mappings = [
    {
      device_name = "/dev/sdx"
      ebs = {
        iops        = 0
        volume_size = 30
        volume_type = "gp2"
      }
    },
  ]
  network_interfaces = [
    {
      security_groups             = [dependency.sg_alb.outputs.security_group_id],
      device_index                = 0
      associate_public_ip_address = true
      ipv4_address_count          = 0
      ipv4_addresses              = []
      ipv4_prefix_count           = 0
      ipv4_prefixes               = []
      ipv6_address_count          = 0
      ipv6_addresses              = []
      ipv6_prefix_count           = 0
      ipv6_prefixes               = []
      network_card_index          = 0

    }
  ]

  security_groups = [dependency.sg_alb.outputs.security_group_id]
  // user_data script use to attach the ec2 machines to ECS cluster
  user_data = base64encode(templatefile("./user_data.sh.tpl", { ecs_cluster_name = "${local.locals.project_name}-plugin-dev-ecs-cluster" }))

  create_iam_instance_profile = true
  iam_instance_profile_name   = "ecsInstanceProfileRole-${local.locals.project_name}-dev"
  force_detach_policies       = false
  iam_role_use_name_prefix    = false
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    AmazonElasticFileSystemClientFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  }

  min_size              = 2
  max_size              = 3
  desired_capacity      = 3
  protect_from_scale_in = true
  vpc_zone_identifier   = dependency.vpc.outputs.private_subnets
  health_check_type     = "EC2"
  tags = {
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    Region      = "${local.locals.aws_region}"
    Owner       = "${local.locals.Owner}"
    ManagedBy   = "${local.locals.ManagedBy}"
    ProjectCode = "${local.locals.project_code}"

  }
}
