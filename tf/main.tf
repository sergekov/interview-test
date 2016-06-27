# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "interview_prod" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "interview_prod" {
  vpc_id = "${aws_vpc.interview_prod.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.interview_prod.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.interview_prod.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "interview_prod_web" {
  vpc_id                  = "${aws_vpc.interview_prod.id}"
  availability_zone       = "ap-southeast-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_subnet" "interview_prod_web_b" {
  vpc_id                  = "${aws_vpc.interview_prod.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

}





resource "aws_elb" "web-elb" {
  name = "web-elb-resource"
 # vpc_id      = "${aws_vpc.interview_prod.id}"

  # The same availability zone as our instances
  #availability_zones = ["${split(",", var.availability_zones)}"]
  availability_zones = ["ap-southeast-2a"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

}

resource "aws_autoscaling_group" "web-asg" {
  # availability_zones = ["${split(",", var.availability_zones)}"]
  # availability_zones = ["ap-southeast-2a"]
  name = "web-asg-resource"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  wait_for_capacity_timeout = "500s"
  health_check_grace_period = "1000"
  health_check_type = "EC2"
  # force_delete = 
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers = ["${aws_elb.web-elb.name}"]
  vpc_zone_identifier = ["${aws_subnet.interview_prod_web.*.id}"]
  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = "true"
  }
}


resource "aws_launch_configuration" "web-lc" {
  name = "web-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.web-sg.id}"]
  user_data = "${file("userdata-web.sh")}"
#  key_name = "${var.key_name}"
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web-sg" {
  name        = "web_sg_pub"
  description = "interview_web_sg_pub"
  vpc_id      = "${aws_vpc.interview_prod.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}



