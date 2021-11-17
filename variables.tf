# Reusing the Parameter Store CIDR for the VPC to generate the local data structure - data.aws_ssm_parameter.awsctrlcidr.value

data "aws_ssm_parameter" "awsctrlcidr" {
  name = "awesctrlcidr"
}

data "aws_ssm_parameter" "awsregion" {
  name = "awesregion"
}

data "aws_ssm_parameter" "type" {
  name = "awestype"
}


locals {

  cidrbits      = tonumber(split("/", data.aws_ssm_parameter.awsctrlcidr.value)[1])
  newbits       = 28 - local.cidrbits
  netnum        = pow(2, local.newbits)
  subnet_zone_a     =  cidrsubnet(data.aws_ssm_parameter.awsctrlcidr.value, local.newbits, local.netnum - 2)
  subnet_zone_b     =  cidrsubnet(data.aws_ssm_parameter.awsctrlcidr.value, local.newbits, local.netnum - 1)
  images_byol     = jsondecode(data.http.avx_iam_id.body).BYOL
  images_platinum = jsondecode(data.http.avx_iam_id.body).MeteredPlatinum
  ami_id          = data.aws_ssm_parameter.type.value == "BYOL" || data.aws_ssm_parameter.type.value == "byol"? local.images_byol[data.aws_ssm_parameter.awsregion.value] : local.images_platinum[data.aws_ssm_parameter.awsregion.value]
}

data http avx_iam_id {
  url = "https://s3-us-west-2.amazonaws.com/aviatrix-download/AMI_ID/ami_id.json"
  request_headers = {
    "Accept" = "application/json"
  }
}

