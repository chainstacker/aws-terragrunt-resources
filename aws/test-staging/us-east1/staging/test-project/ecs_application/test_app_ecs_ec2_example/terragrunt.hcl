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

dependency "sg_alb" {
  config_path = "../../security_groups/alb"
  mock_outputs = {
    security_group_id = "sg-012342a929807e708"
  }
}

dependency "alb" {
  config_path = "../../alb"
  mock_outputs = {
    target_group_arns = [
      "arn:aws:elasticloadbalancing:us-east-2:599564732950:targetgroup/dev-zksync-remix-rocket-tg/0909d016b2ef1ea5"
    ]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "sg" {
  config_path = "../../security_groups/ecs_service"
  mock_outputs = {
    security_group_id = "sg-066878f69fc83a071"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecs_cluster" {
  config_path = "../../ecs_cluster"
  mock_outputs = {
    cluster_arn = "arn:aws:ecs:us-east-2:599564732950:cluster/zksync-remix-plugin-dev-ecs-cluster"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}


inputs = {
  sg_alb_id                          = dependency.sg_alb.outputs.security_group_id
  security_group_ids                 = [dependency.sg.outputs.security_group_id, dependency.sg_alb.outputs.security_group_id]
  cluster_arn                        = dependency.ecs_cluster.outputs.cluster_arn
  deployment_minimum_healthy_percent = 100
  name                               = "test-app-dev-svc"
  launch_type                        = "EC2"
  cpu                                = 2048
  memory                             = 8192
  assign_public_ip                   = false
  requires_compatibilities           = ["EC2"]
  container_definitions = {
    rocket = {
      cpu = 0

      essential = true
      image     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
      port_mappings = [
        {
          containerPort = 8000
          hostPort      = 8000,
          protocol      = "tcp"
        }
      ]
      systemControls         = []
      volumesFrom            = []
      mountPoints            = []
      privileged             = null
      pseudoTerminal         = null
      readonlyRootFilesystem = false
      startTimeout           = []
      stopTimeout            = []
      secrets = []
      environment = [
        {
          "name" : "ENVIRONMENT",
          "value" : "dev"
        },
        {
          "name" : "PROMETHEUS_USERNAME",
          "value" : "923"
        },
        {
          "name" : "WORKER_THREADS",
          "value" : "1"
        },
        {
          "name" : "RUST_LOG",
          "value" : "INFO"
        }
      ]

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/test-app-dev-log-group"
          awslogs-region        = "${local.locals.aws_region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }

  family                             = "test-app-remix-dev-rocket"
  task_exec_iam_role_use_name_prefix = false
  task_exec_iam_role_name            = "task-execution-role-${local.locals.project_name}-rocket-dev"
  create_task_exec_iam_role          = true
  task_exec_iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    AmazonEFSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }
  tasks_iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonEFSCSIDriverPolicy            = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }
  subnet_ids = dependency.vpc.outputs.private_subnets
  load_balancer = {
    service = {
      target_group_arn = dependency.alb.outputs.target_group_arns[0]
      container_name   = "test-app"
      container_port   = 8000
    }
  }
  create_security_group = false

}