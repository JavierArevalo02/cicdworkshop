terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

# Create a VPC
resource "aws_vpc" "homework5" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "homework5Endava-vpc",
    homework: "endava"
  }
}
#Create Subnet
resource "aws_subnet" "homework5"{
  vpc_id = aws_vpc.homework5.id
  cidr_block = "192.168.0.0/28"
  tags = {
    Name = "homework5Endava-subnet",
    homework: "endava"
  }
}
#Create internet gateway
resource "aws_internet_gateway" "homework5" {
  vpc_id = aws_vpc.homework5.id
  tags = {
    Name = "homework5Endava-internetGateway",
    homework: "endava"
  }
}
#Create route table
resource "aws_route_table" "homework5" {
  vpc_id = aws_vpc.homework5.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.homework5.id
  }

  tags = {
    Name = "homework5Endava-routeTable",
    homework: "endava"
  }
}
#Association routable to subnet
resource "aws_route_table_association" "homework5" {
  subnet_id      = aws_subnet.homework5.id
  route_table_id = aws_route_table.homework5.id
}

#Create a security group
resource "aws_security_group" "homework5" {
  name        = "allow http and ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.homework5.id
  tags = {
    Name = "homework5Endava-SG",
    homework: "endava"
  }
}
#Create rules to security group
resource "aws_security_group_rule" "homework5" {
  for_each          = local.nsgrules 
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.homework5.id
}
#Create network interface to Virtual machine
resource "aws_network_interface" "homework5" {
  subnet_id   = aws_subnet.homework5.id
  private_ips = ["192.168.0.10"]

  tags = {
    Name = "homework5Endava-netInterface",
    homework: "endava"
  }
}
#Create key to acces to the machine
resource "tls_private_key" "homework5" {
  algorithm = "RSA"
}

resource "local_file" "homework5" {
  content  = tls_private_key.homework5.private_key_pem
  filename = "mykey.pem"
}

resource "aws_key_pair" "homework5" {
  key_name   = "homework5Key"
  public_key = tls_private_key.homework5.public_key_openssh
}
#Create virtual machine
resource "aws_instance" "homework5" {
  ami           = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.homework5.key_name

  network_interface {
    network_interface_id = aws_network_interface.homework5.id
    device_index         = 0
  }
  tags = {
    Name = "homework5Endava-EC2",
    homework: "endava"
  }
  user_data = filebase64(var.commands)
}
#Associate elastic ip to instance
resource "aws_eip" "lb" {
  instance = aws_instance.homework5.id
  vpc      = true
}
#Create association from security group to resources
resource "aws_network_interface_sg_attachment" "homework5" {
  security_group_id    = aws_security_group.homework5.id
  network_interface_id = aws_instance.homework5.primary_network_interface_id
}