#
# 1) prereqsctrl.tf - CREATE VPC, SSH Key, IGW, Subnets, CIDR
#

# 2) CREATE IAM ROLES

# Creates IAM
# aviatrix-role-ec2
# aviatrix-role-app

module "iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=terraform_0.14"
}

# 3) BEFORE DEPLOYING CONTROLLER - Accept the terms and subscribe to the Aviatrix Controller in the AWS Marketplace - link in errro message that will appear


module "aviatrixcontroller" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=terraform_0.14"
  vpc               = aws_vpc.avtx_ctrl_vpc.id
  subnet            = aws_subnet.avtx_ctrl_subnet_a.id
  keypair           = module.avx_ctrl_key.key_pair_key_name
  ec2role           = module.iam_roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = ["0.0.0.0/0"]
  type              = "MeteredPlatinumCopilot"
}

# 4) ONBOARDING AWS ACCOUNT ONCE CONTROLLER IS UP ###

## READ PARAMETERS from AWS Parameter Store and Populate the CTRL_IP one for future usage of the Aviatrix Provider

### AWS ACCOUNT ID - prepopulated in AWS PS (param store)
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

### PROVIDERS.YAML will use this info #

## ONBOARD AWS ACCOUNT 

data "aws_ssm_parameter" "awsaccountname" {
  name = "awesaccountname"
}

resource "aviatrix_account" "aws_account" {
  account_name       = data.aws_ssm_parameter.awsaccountname.value
  cloud_type         = 1
  aws_account_number = data.aws_ssm_parameter.awsctrlaccount.value
  aws_iam            = true
  aws_role_app       = "arn:aws:iam::${data.aws_ssm_parameter.awsctrlaccount.value}:role/${module.iam_roles.aviatrix-role-app-name}"
  aws_role_ec2       = "arn:aws:iam::${data.aws_ssm_parameter.awsctrlaccount.value}:role/${module.iam_roles.aviatrix-role-ec2-name}"
}

# 5) CREATE TRANSIT

data "aws_ssm_parameter" "awstransitcidr" {
  name = "awestransitcidr"
}

data "aws_ssm_parameter" "awsspokecidr" {
  name = "awesspokecidr"
}

module "transit_aws_1" {
  source  = "terraform-aviatrix-modules/aws-transit/aviatrix"
  version = "v4.0.2"

  name = "TestTransit"
  cidr = data.aws_ssm_parameter.awstransitcidr.value
  region = data.aws_ssm_parameter.awsregion.value
  account = data.aws_ssm_parameter.awsaccountname.value
}

# 6) CREATE SPOKE & ATTACH
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "4.0.3"

  name            = "TestSpoke"
  cidr            = data.aws_ssm_parameter.awsspokecidr.value
  region          = data.aws_ssm_parameter.awsregion.value
  account         = data.aws_ssm_parameter.awsaccountname.value
  transit_gw      = module.transit_aws_1.transit_gateway.name
}

