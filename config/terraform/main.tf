variable "ssh-key" {
    description = "Name of SSH key in AWS EC2. Must be saved under same name in ~/.ssh"
}

provider "aws" {
    profile = "personal"
    region = "us-east-1"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

data "aws_ami" "centos" {
    most_recent = true
    filter {
        name = "name"
        values = ["CentOS Linux 7 x86_64*"]
    }
    owners = ["410186602215"]
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App access from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {
    key_name = "${var.ssh-key}"
    ami = "${data.aws_ami.centos.id}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.main.id}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
}

resource "null_resource" "dependencies" {
    provisioner "remote-exec" {
        script = "${path.module}/provision/install-deps.sh"
    }
    triggers {
        instance_id = "${aws_instance.web.id}"
    }
    connection {
        type = "ssh"
        host = "${aws_instance.web.public_ip}"
        user = "centos"
        private_key = "${file("~/.ssh/${var.ssh-key}.pem")}"
    }
}

resource "null_resource" "application" {
    depends_on = ["null_resource.dependencies"]
    connection {
        type = "ssh"
        host = "${aws_instance.web.public_ip}"
        user = "centos"
        private_key = "${file("~/.ssh/${var.ssh-key}.pem")}"
    }
    provisioner "file" {
        source = "${path.module}/../../index.js"
        destination = "/app/index.js"
    }
    provisioner "remote-exec" {
        script = "${path.module}/provision/npm-install.sh"
    }
}

output "instance-address" {
    value = "${aws_instance.web.public_ip}"
}

output "http-service" {
    value = "http://${aws_instance.web.public_ip}:3000"
}
