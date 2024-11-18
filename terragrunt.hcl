
locals {
  region = "us-east-1"
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"

  # Only these AWS Account IDs may be operated on by this template
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = "shashwat-terraform-bucket"
    region  = local.region
    key = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks-table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}