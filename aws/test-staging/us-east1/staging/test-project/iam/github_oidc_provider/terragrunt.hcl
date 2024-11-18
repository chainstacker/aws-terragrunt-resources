include {
  path = find_in_parent_folders()
}

include "iam" {
  path = "${get_repo_root()}/modules/terraform-aws-modules_iam-oidc-provider.hcl"
}

inputs = {
   # Optional: List of additional thumbprints to be added
  additional_thumbprints = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  # Optional: List of client IDs (audiences)
  client_id_list = []

  # The URL of the GitHub OIDC identity provider
  url = "https://token.actions.githubusercontent.com"
}
