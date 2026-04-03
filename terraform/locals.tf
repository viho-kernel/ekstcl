locals {
  ami     = data.aws_ami.joindevops.id
  aws_vpc = data.aws_vpc.default.id
}
