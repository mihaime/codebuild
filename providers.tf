provider "aviatrix" {
  controller_ip = aws_ssm_parameter.aviatrix_ctrl_ip.value
  username      = data.aws_ssm_parameter.aviatrix_username.value
  password      = data.aws_ssm_parameter.aviatrix_password.value
}

provider "aws" {
  region = "eu-west-3"
}
