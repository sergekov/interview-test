# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_eip" "nat_eip" {
  count    = "${length(split(",", var.public_subnet_cidr))}"
  vpc = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "interview_prod_gw" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_nat_gateway" "nat-gw" {
  count = "${length(split(",", var.public_subnet_cidr))}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.interview_public.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.interview_prod_gw"]
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.interview_prod_gw.id}"
}

# Grant the private subnets internet access on via NAT instance
resource "aws_route" "internet_access_nat" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.nat-gw.id}"
}


resource "aws_subnet" "interview_public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${element(split(",", var.public_subnet_cidr), count.index)}"
  availability_zone       = "${element(split(",", var.availability_zones), count.index)}"
  count                   = "${length(split(",", var.cidrs))}"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.name.public}.${element(split(",", var.availability_zones), count.index)}"
  }
}


# Create a subnet to launch our instances into
#resource "aws_subnet" "interview_prod_web_a" {
#  vpc_id                  = "${aws_vpc.default.id}"
#  availability_zone       = "ap-southeast-2a"
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true

#  lifecycle {
#    create_before_destroy = true
#  }

#}


#resource "aws_subnet" "interview_prod_web_b" {
#  vpc_id                  = "${aws_vpc.default.id}"
#  cidr_block              = "10.0.2.0/24"
#  availability_zone       = "ap-southeast-2b"
#  map_public_ip_on_launch = true

#  lifecycle {
#    create_before_destroy = true
#  }

#}

resource "aws_subnet" "interview_prod_web_c" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-2c"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_subnet" "interview_prod_app_a" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "ap-southeast-2a"
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "interview_prod_app_b" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "ap-southeast-2b"
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "interview_prod_app_c" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "ap-southeast-2a"
  cidr_block              = "10.0.103.0/24"
  map_public_ip_on_launch = false

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elb" "web-elb" {
  name = "web-elb-resource"
  # vpc_id = "${aws_vpc.default.id}"

  # The same availability zone as our instances
  #availability_zones = ["${split(",", var.availability_zones)}"]
  # availability_zones = [ "ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c" ]
  # subnets = [ "${aws_subnet.interview_prod_web_a.id}", "${aws_subnet.interview_prod_web_b.id}", "${aws_subnet.interview_prod_web_c.id}" ]
  subnets = [ "${element(aws_subnet.interview_public.*.id, count.index)}" ]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

}

resource "aws_autoscaling_group" "web-asg" {
  # availability_zones = ["${split(",", var.availability_zones)}"]
  # availability_zones = [ "ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c" ]
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
  vpc_zone_identifier = ["${aws_subnet.interview_prod_web_a.*.id}", "${aws_subnet.interview_prod_web_b.*.id}", "${aws_subnet.interview_prod_web_c.*.id}"]
  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = "true"
  }
}


resource "aws_autoscaling_group" "app-asg" {
  # availability_zones = ["${split(",", var.availability_zones)}"]
  # availability_zones = [ "ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c" ]
  name = "app-asg-resource"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  wait_for_capacity_timeout = "500s"
  health_check_grace_period = "1000"
  health_check_type = "EC2"
  # force_delete = 
  launch_configuration = "${aws_launch_configuration.app-lc.name}"
  # load_balancers = ["${aws_elb.web-elb.name}"]
  vpc_zone_identifier = ["${aws_subnet.interview_prod_app_a.*.id}", "${aws_subnet.interview_prod_app_b.*.id}", "${aws_subnet.interview_prod_app_c.*.id}"]
  tag {
    key = "Name"
    value = "app-asg"
    propagate_at_launch = "true"
  }
}


resource "aws_launch_configuration" "web-lc" {
  name = "web-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.web-sg.id}"]
  user_data = "${file("./userdata-web.sh")}"
  key_name = "${var.key_name}"
}

resource "aws_launch_configuration" "app-lc" {
  name = "app-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.app-sg.id}"]
  user_data = "${file("./userdata-app.sh")}"
  key_name = "${var.key_name}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web-sg" {
  name        = "web_sg_pub"
  description = "interview_web_sg_pub"
  vpc_id      = "${aws_vpc.default.id}"

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

resource "aws_security_group" "app-sg" {
  name        = "app_sg_pub"
  description = "interview_app_sg"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/0"]
  }
}


resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}



