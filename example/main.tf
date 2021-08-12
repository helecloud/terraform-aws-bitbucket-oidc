data "aws_iam_policy_document" "pipeline_role" {
  statement {
    actions   = ["lambda:InvokeFunction", "logs:FilterLogEvents"]
    resources = ["*"]
  }
}

# Create the IAM provider with one role
module "bitbucket_oidc" {
  source = "../."

  workspace_name = "FaridN"
  workspace_uuid = "c95b4694-9b82-4fe5-9e2f-00ffac14cf93"
  #  You can get in the repository settings in the OpenID connect provider.

  roles = {
    role1 = {
      name                 = "BitbucketPipelineRepo1"
      allowed_subjects     = ["{573817ba-2f91-4ae3-8384-ff2cbc4caaa1}*"]
      inline_policies_json = [data.aws_iam_policy_document.pipeline_role.json]
    }
  }

  tags = {
    exampleTag = "exampleValue"
  }
}

output "role_arn" {
  description = "Use this as AWS_ROLE_ARN environmental variable in your pipeline."
  value       = module.bitbucket_oidc.roles.role1.arn
}
