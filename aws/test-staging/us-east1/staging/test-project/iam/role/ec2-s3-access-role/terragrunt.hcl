include {
  path = find_in_parent_folders()
}

include "iam" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_iam-role.hcl"
}

dependency "policy" {
  config_path = "../../policy/s3-full-access-policy"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    arn = "arn:aws:iam::123456789012:policy/mock-policy"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}


inputs = {
  role_name = "ec2-s3-access-role"
  create_custom_role_trust_policy = true
  create_instance_profile = true
  create_role = true
  custom_role_policy_arns = [dependency.policy.outputs.arn]
  custom_role_trust_policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
    })
}