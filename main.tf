module "aviatrixcontroller" {
  source            = "github.com/AviatrixSystems/terraform-modules.git//aviatrix-controller-build?ref=terraform_0.14"
  vpc               = "abcd"
  subnet            = "subnet-9x3237xx"
  keypair           = "keypairname"
  ec2role           = "aviatrix-role-ec2"
  incoming_ssl_cidr = ["0.0.0.0/0"]
}

/*
something
*/
