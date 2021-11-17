/* IAM ROLES */

# Creates IAM
# aviatrix-role-ec2
# aviatrix-role-app

module "iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=terraform_0.14"
}

#
# VPC, SSH Key, IGW, Subnets, CIDR - prereqsctrl.tf
#

# !!! BEFORE DEPLOYING CONTROLLER - Accept the terms and subscribe to the Aviatrix Controller in the AWS Marketplace.
# https://aws.amazon.com/marketplace/pp?sku=zemc6exdso42eps9ki88l9za

module "aviatrixcontroller" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=terraform_0.14"
  vpc               = aws_vpc.avtx_ctrl_vpc.id
  subnet            = aws_subnet.avtx_ctrl_subnet_a.id
  keypair           = module.avx_ctrl_key.key_pair_key_name
  ec2role           = module.iam_roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = ["0.0.0.0/0"]
  type              = "MeteredPlatinumCopilot"
}

### ONBOARDING AWS ACCOUNT ONCE CONTROLLER IS UP ###

## AWS ACCOUNT ID - prepopulated in AWS PS (param store)
data "aws_ssm_parameter" "awsctrlaccount" {
  name = "cspaccount"
}

resource "aws_ssm_parameter" "aviatrix_ctrl_ip" {
  name = "aviatrix_ctrl_eip"
  type = "String"
  value = module.aviatrixcontroller.public_ip
}

data "aws_ssm_parameter" "aviatrix_username" {
  name = "aviatrix_username"
}

data "aws_ssm_parameter" "aviatrix_password" {
  name = "aviatrix_password"
  with_decryption = true
}

# PROVIDERS.YAML will use this info #

### ONBOARD AWS ACCOUNT ###
resource "aviatrix_account" "aws_account" {
  account_name       = "AWSMihai"
  cloud_type         = 1
  aws_account_number = data.awsctrlaccount.value
  aws_iam            = true
  aws_role_app       = "arn:aws:iam::${data.awsctrlaccount.value}:role/${module.iam_roles.aviatrix-role-app-name}"
  aws_role_ec2       = "arn:aws:iam::${data.awsctrlaccount.value}:role/${module.iam_roles.aviatrix-role-app-name}"
}

