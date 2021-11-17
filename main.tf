/* IAM ROLES */

# Creates
# aviatrix-role-ec2
# aviatrix-role-app

# IAM

module "iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-iam-roles?ref=terraform_0.14"
}

# VPC, SSH Key, IGW, Subnets, CIDR - prereqsctrl.tf

# !!! BEFORE DEPLOYING CONTROLLER - Accept the terms and subscribe to the Aviatrix Controller in the AWS Marketplace.
# https://aws.amazon.com/marketplace/pp?sku=zemc6exdso42eps9ki88l9za

module "aviatrixcontroller" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=terraform_0.14"
  vpc               = aws_vpc.avtx_ctrl_vpc.id
  subnet            = aws_subnet.avtx_ctrl_subnet_a.id
  keypair           = module.avx_ctrl_key.key_pair_key_name
  ec2role           = module.iam_roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = ["0.0.0.0/0"]
}

data "aws_ssm_parameter" "awsctrlaccount" {
  name = "cspaccount"
}

