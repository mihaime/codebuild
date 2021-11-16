/* IAM ROLES */

data "aws_ssm_parameter" "awsctrlaccount" {
  name = "cspaccount"
}

data.aws_ssm_parameter.awsctrlaccount.value

module "iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=terraform_0.14"
}

/* 
The AWS account ID where the Aviatrix Controller was/will be launched. This is only required if you are creating roles for the secondary account different from the account where controller was/will be launched. DO NOT use this parameter if this Terraform module is applied on the AWS account of your controller.

Same definition using als extra param this for the latter case:
  external-controller-account-id = ""

*/

