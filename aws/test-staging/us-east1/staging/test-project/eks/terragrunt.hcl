include {
  path = find_in_parent_folders()
}

include "eks" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_eks.hcl"
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

inputs = {
    cluster_name    = "p2p-cluster"
    cluster_version = "1.27"
    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
    }
    vpc_id = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets
    eks_create_aws_auth_configmap       = false
    eks_manage_aws_auth_configmap       = true

    aws_auth_users = [
        {
            userarn  = "arn:aws:iam::<AWS_ID>:user/<USER>"
            username = "<USERNAME>"
            groups   = ["system:masters"]
        }
    ]
    # EKS Managed Node Group(s)
    eks_managed_node_group_defaults = {
        instance_types = ["t2.micro"]
    }
    eks_managed_node_groups = {
        example = {
        min_size     = 1
        max_size     = 1
        desired_size = 1
        instance_types = ["t3.micro"]
        capacity_type  = "SPOT"
        }
    }

  tags = {
    Terraform   = "true"
    Environment = "${local.locals.environment_name}"
    Project     = "${local.locals.project_name}"
    ProjectCode = "${local.locals.project_code}"
  }
}
