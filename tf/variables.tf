variable "public_key_path" {
  description = "Dev User key"
  default = "~/.ssh/terraform.pub"
}

variable "private_key_path" {
  description = "Dev User key"
  default = "~/.ssh/terraform"
}

variable "key_name" {
  description = "test user"
  default = "test"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "ap-southeast-2"
}

# CentOS 7
variable "aws_amis" {
  default = {
#    ap-southeast-2 = "ami-91c7eff2"
#    ap-southeast-2 = "ami-bd523087"
     ap-southeast-2 = "ami-d9d7f9ba"
#    ap-southeast-2 = "ami-bd523087"
  }
}



variable "name" { 
  default = {
    public = "interview_prod_web"  
    private = "interview_prod_app"
  }
}

variable "availability_zones" {
  default = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
  description = "Availability zones for the web application"
}

variable "subnet_azs" {
  default = "aws_subnet.interview_prod_web_a,aws_subnet.interview_prod_web_b,aws_subnet.interview_prod_web_c"
  description = "The VPC subnet IDs"
}


variable "cidrs" {
  default = "3"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.101.0/24,10.0.102.0/24,10.0.103.0/24"
}

variable "public_mgmt_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.51.0/24"
}

variable "instance_type" {
  default = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "3"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default = "2"
}