resource "aws_iam_openid_connect_provider" "bitbucket" {
  client_id_list  = ["ari:cloud:bitbucket::workspace/${var.workspace_uuid}"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
  url             = "https://api.bitbucket.org/2.0/workspaces/${var.workspace_name}/pipelines-config/identity/oidc"
  tags            = var.tags
}

data "aws_iam_policy_document" "bitbucket_assume_role_policy" {
  for_each = var.roles
  statement {
    principals {
      identifiers = [aws_iam_openid_connect_provider.bitbucket.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = "api.bitbucket.org/2.0/workspaces/${var.workspace_name}/pipelines-config/identity/oidc:sub"
      values   = each.value.allowed_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  for_each           = var.roles
  name               = each.value.name
  assume_role_policy = data.aws_iam_policy_document.bitbucket_assume_role_policy[each.key].json
  dynamic "inline_policy" {
    for_each = each.value.inline_policies_json
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }

  tags = var.tags
}
