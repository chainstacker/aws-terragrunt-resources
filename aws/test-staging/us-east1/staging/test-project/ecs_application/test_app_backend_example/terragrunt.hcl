include {
  path = find_in_parent_folders()
}

include "ecs" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_ecs-service.hcl"
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
    vpc_id = "vpc-012341a0dd8b01234"
    public_subnets = [
      "subnet-003601fe683fd1113",
      "subnet-0f0787cffc6ae1113",
      "subnet-00e05034aa90b1113"
    ],
    private_subnets = [
      "subnet-003601fe683fd1111",
      "subnet-0f0787cffc6ae1112",
      "subnet-00e05034aa90b1112"
    ],
  }
}

dependency "sg_alb" {
  config_path                             = "../../security_groups/alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-02092eea015a2eade"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "alb" {
  config_path                             = "../../alb"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    target_group_arns = [
      "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/bluegreentarget1/209a844cd01825a4"
    ]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "sg" {
  config_path                             = "../../security_groups/code_auditor_backend"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    security_group_id = "sg-02092eea015a2eade"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecs_cluster" {
  config_path                             = "../../ecs_cluster"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    cluster_arn = "arn:aws:ecs:us-east-1:123456789012:cluster/panther-web-cluster"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  sg_alb_id          = dependency.sg_alb.outputs.security_group_id
  security_group_ids = [dependency.sg.outputs.security_group_id]
  cluster_arn        = dependency.ecs_cluster.outputs.cluster_arn

  name             = "${local.locals.project_name}-backend-app"
  cpu              = 1024
  memory           = 2048
  assign_public_ip = true
  container_definitions = {
    test-app-backend = {
      cpu    = 512
      memory = 1024

      essential = true
      image     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
      port_mappings = [
        {
          name          = "test-app-backend"
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          "name" : "DOPPLER_TOKEN",
          "valueFrom" : "arn:aws:secretsmanager:eu-central-1:654634234236251:secret:TEST_APP_BACKEND_SECRET-JcEINO::"
        }
      ]

      readonly_root_filesystem  = false
      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "test-app-backend-agent"
          awslogs-region        = "${local.locals.aws_region}"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "playground"
        }
      }
    }
  }

  task_exec_iam_role_name     = "${local.locals.project_name}-backend-app-ecs-role"
  create_task_exec_iam_role   = true
  task_exec_iam_role_policies = { logs_full = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess" }
  subnet_ids                  = dependency.vpc.outputs.private_subnets
  load_balancer = {
    service = {
      target_group_arn = dependency.alb.outputs.target_group_arns[0]
      container_name   = "test-app-backend"
      container_port   = 8000
    }
  }
  create_security_group = false
}
