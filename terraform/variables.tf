variable "ingress_rules" {
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))

  default = {
    SSH = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allowing ssh access from itnernet"
    },
    HTTP = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allowing HTTP access from internet"
    },

    eight = {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allowing HTTP access from internet"
    },

    all = {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ALL Traffic allowing just for testing purpose."
    }
  }



}

variable "aws_access_key" {
  description = "AWS Access Key ID for configuring the workstation"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key for configuring the workstation"
  type        = string
  sensitive   = true
}

variable "ssh_password" {
  description = "SSH password for ec2-user to run destroy-time provisioner"
  type        = string
  sensitive   = true
}
