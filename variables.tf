variable "workspace_uuid" {
  description = "Workspace UUID. You can get it in the repository settings in the OpenID connect provider. Don't include the brackets and make sure it is lower cased."
  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.workspace_uuid))
    error_message = "The uuid format is not matching. Make sure it is lowercased and brackets are not included. Here's a valid example: 8a1f1c70-cbc0-452c-81ce-07534945e18b."
  }
}

variable "workspace_name" {
  description = "The name of the workspace."
}

variable "roles" {
  default = {}
  type = map(object({
    name                 = string
    allowed_subjects     = list(string)
    inline_policies_json = list(string)
  }))
  description = "A map of roles to create. The roles will be exposed in the output with their same key. Allowed subjects will be matched against the sub claim and they can be specified with wildcard. More info about their format here: https://support.atlassian.com/bitbucket-cloud/docs/deploy-on-aws-using-bitbucket-pipelines-openid-connect/#Using-claims-in-ID-tokens-to-limit-access-to-the-IAM-role-in-AWS. inline_policies_json is a list of json strings to attach as inline policies."
}

variable "tags" {
  description = "Tags to apply to all resources."
  default     = {}
}
