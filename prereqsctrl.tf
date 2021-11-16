/* Fetch Using: data.aws_ssm_parameter.awsctrlaccount.value */

module "avx_ctrl_key" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "avx_ctrl_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9lhwk6x8eC+XDT8c0NQr4mxGfCKqCdfWqGkIzaC952Vg/6TKe/YpuiWibMVMUoRg8jm3jFXExzNZoKA86yEDEo4n9u5FVQA7UiFEEMd7fjjwFOQI60K7hgJjEUY/puqVobRnNAXUSk7bfqYAYOw6QK+DLu3z7jK1Mjcb7LJVQPWWZLq1jVSosF5drPbbEo++m2UstA8ZZHewGYdecs6SieeZjcovOrlQv9NONHjiszbN69zyuTcFJheT+U7opadz3WyI8A9zW//bp238+F5pPK+5dBY0+DQHEzGx1XCZzZJ+8mKULbJAb2q3oZG7S+AJ8jABKjCHNHxdZIVf/tHpD3WgqpRDRj6XEQFyXksTNKl+LC/gZmxxddlDMkNab4ZJqUesz0JBlgfV4z9w4Y3EagA1uQmcM8okQZjSq3akfEbhiApN1yiPFAlxTMVgVyqdlNe/kWUoVVbohOFKPVjU/tDaMSQj6iuSVzFONwckFczzTefEhIJdmyP5YxFQWSqeuIXmlpJOswVjnnqgiOijiavZ1dgo1kGhXI9GmZX6ZgvrEcPcNpp20Jrtey2QHssAOxjf1ndq8vydf64kE68rLQLL0sMulcbbW2DmkSTkMOAM5NM9ZBlCRh7ovW88zRsI+EENrINorpBN6Fvlllydppgrabv1WW+4cTFOZVmdYtw== mihaitanasescu@Mihais-MacBook-Pro.local"
}

resource "aws_vpc" "avtx_ctrl_vpc" {
  cidr_block       = data.aws_ssm_parameter.awsctrlcidr.value

  tags = {
    Name = "avx-managment-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.avtx_ctrl_vpc.id
}

resource "aws_subnet" "avtx_ctrl_subnet_a" {
  availability_zone = "${data.aws_ssm_parameter.awsregion.value}a"
  vpc_id     = aws_vpc.avtx_ctrl_vpc.id
  cidr_block = local.subnet_zone_a

  tags = {
    Name = "avx-mgmt-zone-a"
  }
}

resource "aws_subnet" "avtx_ctrl_subnet-b" {
  availability_zone =  "${data.aws_ssm_parameter.awsregion.value}b"
  vpc_id     = aws_vpc.avtx_ctrl_vpc.id
  cidr_block = local.subnet_zone_b

  tags = {
    Name = "avx-mgmt-zone-b"
  }
}


resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.avtx_ctrl_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
