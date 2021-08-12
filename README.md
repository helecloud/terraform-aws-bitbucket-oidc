
A simple Terraform module for setting up IAM roles with a Bitbucket OpenID Connect IAM identity provider in an AWS
account for Bitbucket pipelines.

You can assume role into this IAM role from the steps in your Bitbucket pipeline. With this approach you can deploy to
your AWS accounts from Bitbucket pipelines without usage of IAM users and would not have to worry about accidental
leakage of the IAM user keys.

The IAM roles can only be assumed into via the Bitbucket pipeline repository and potentially the steps that are
specified.

## Usage Example

```terraform
# Generate a policy for the role
data "aws_iam_policy_document" "pipeline_role" {
  statement {
    actions   = ["lambda:*"]
    resources = ["*"]
  }
}

# Create the IAM provider with one role
module "bitbucket_oidc" {
  source = "helecloud/bitbucket-oidc"

  workspace_name = "YOUR_BTIBUCKET_WORKSPACE_NAME"
  workspace_uuid = "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxx"
  #  You can get in the repository settings in the OpenID connect provider.

  roles = {
    role1 = {
      name               = "BitbucketPipelineRepo1"
      allowed_subjects   = ["{xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxx}*"]
      # This is matched against the sub claim, which provided in the following format:
      # {REPOSITORY_UUID}[:{ENVIRONMENT_UUID}]:{STEP_UUID}
      # More info here: https://support.atlassian.com/bitbucket-cloud/docs/deploy-on-aws-using-bitbucket-pipelines-openid-connect/#Using-claims-in-ID-tokens-to-limit-access-to-the-IAM-role-in-AWS
      
      inline_policies_json = [data.aws_iam_policy_document.pipeline_role.json]
      # You can either add policies inline here or add them via aws_iam_role_policy_attachment resource
    }
  }

  tags = {
    exampleTag = "exampleValue"
  }
}

# Attach a managed policy to the role
resource "aws_iam_role_policy_attachment" "pipeline_role" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  role       = module.bitbucket_oidc.roles.role1.name
}

output "role_arn" {
  description = "Use this as AWS_ROLE_ARN environmental variable in your pipeline."
  value       = module.bitbucket_oidc.roles.role1.arn
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.bitbucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.bitbucket_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_roles"></a> [roles](#input\_roles) | A map of roles to create. The roles will be exposed in the output with their same key. Allowed subjects will be matched against the sub claim and they can be specified with wildcard. More info about their format here: https://support.atlassian.com/bitbucket-cloud/docs/deploy-on-aws-using-bitbucket-pipelines-openid-connect/#Using-claims-in-ID-tokens-to-limit-access-to-the-IAM-role-in-AWS. inline\_policies\_json is a list of json strings to attach as inline policies. | <pre>map(object({<br>    name                 = string<br>    allowed_subjects     = list(string)<br>    inline_policies_json = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map` | `{}` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | The name of the workspace. | `any` | n/a | yes |
| <a name="input_workspace_uuid"></a> [workspace\_uuid](#input\_workspace\_uuid) | Workspace UUID. You can get it in the repository settings in the OpenID connect provider. Don't include the brackets and make sure it is lower cased. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provider"></a> [provider](#output\_provider) | The OpenID Connect IAM provider |
| <a name="output_roles"></a> [roles](#output\_roles) | IAM roles created mapping. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
```sh
pre-commit install
```


- Configure golang deps for tests
```sh
> go get github.com/gruntwork-io/terratest/modules/terraform
> go get github.com/stretchr/testify/assert
```



### Tests

- Tests are available in `test` directory

- In the test directory, run the below command
```sh
go test
```

## Authors

This project is authored by below people

- Farid Nouri Neshat

> This project was generated by [generator-tf-module](https://github.com/sudokar/generator-tf-module)

MIT License

Copyright (c) 2021 Helecloud

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
