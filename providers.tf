provider "aviatrix" {
  controller_ip = data.aviatrix_ctrl_ip.value
  username      = data.aviatrix_username.value
  password      = data.aviatrix_password.value
}

provider "aws" {
  region = "eu-west-3"
}
