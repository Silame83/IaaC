provider "aws" {
  profile = "default"
  region = "eu-west-3"
}

resource "aws_vpc" "stage_qa" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = "Stage QA VPC"
    Env = "QA"
  }
}

resource "aws_security_group" "ECSCluster" {
  name = "SG-ECS-cluster-qa-replica"
  description = "SG for ECS Cluster"
  vpc_id = "${aws_vpc.stage_qa.id}"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "Allow SSH Port"
  }
}

resource "aws_subnet" "PrivateSubnetA" {
  vpc_id = "${aws_vpc.stage_qa.id}"
  cidr_block = "10.30.10.0/24"
  depends_on = [
    aws_nat_gateway.NATGW]

  tags = {
    Name = "Private Subnet A"
    Env = "QA"
  }
}

resource "aws_subnet" "PrivateSubnetB" {
  vpc_id = "${aws_vpc.stage_qa.id}"
  cidr_block = "10.30.11.0/24"
  depends_on = [
    aws_nat_gateway.NATGW]

  tags = {
    Name = "Private Subnet B"
    Env = "QA"
  }
}

resource "aws_subnet" "PrivateSubnetC" {
  vpc_id = "${aws_vpc.stage_qa.id}"
  cidr_block = "10.30.12.0/24"
  depends_on = [
    aws_nat_gateway.NATGW]

  tags = {
    Name = "Private Subnet C"
    Env = "QA"
  }
}

resource "aws_subnet" "PublicSubnetA" {
  vpc_id = "${aws_vpc.stage_qa.id}"
  cidr_block = "10.30.0.0/24"
  depends_on = [
    aws_internet_gateway.IGW]

  tags = {
    Name = "Public Subnet A"
    Env = "QA"
  }
}

resource "aws_subnet" "PublicSubnetB" {
  cidr_block = "10.30.1.0/24"
  vpc_id = "${aws_vpc.stage_qa.id}"
  depends_on = [
    aws_internet_gateway.IGW]

  tags = {
    Name = "Public Subnet B"
    Env = "QA"
  }
}

resource "aws_subnet" "PublicSubnetC" {
  cidr_block = "10.30.2.0/24"
  vpc_id = "${aws_vpc.stage_qa.id}"
  depends_on = [
    aws_internet_gateway.IGW]

  tags = {
    Name = "Public Subnet C"
    Env = "QA"
  }
}

resource "aws_subnet" "MongoSubnet" {
  cidr_block = "10.30.250.0/24"
  vpc_id = "${aws_vpc.stage_qa.id}"

  tags = {
    Name = "Mongo Subnet"
    Env = "QA"
  }
}

resource "aws_subnet" "NATSubnet" {
  cidr_block = "10.30.255.0/24"
  vpc_id = "${aws_vpc.stage_qa.id}"

  tags = {
    Name = "NAT Subnet"
    Env = "QA"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.stage_qa.id}"

  tags = {
    Name = "Internet Gateway"
    Env = "QA"
  }
}

resource "aws_eip" "NAT_IP" {
  vpc = true

  tags = {
    Name = "NAT IP for NAT Gateway"
    Env = "QA"
  }
}

resource "aws_nat_gateway" "NATGW" {
  allocation_id = "${aws_eip.NAT_IP.id}"
  subnet_id = "${aws_subnet.NATSubnet.id}"

  tags = {
    Name = "NAT Gateway"
    Env = "QA"
  }
}

resource "aws_route_table" "PublicRT" {
  vpc_id = "${aws_vpc.stage_qa.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }
  tags = {
    Name = "Public RT"
    Env = "QA"
  }
}
resource "aws_route_table" "NATRT" {
  vpc_id = "${aws_vpc.stage_qa.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.NATGW.id}"
  }
  tags = {
    Name = "NAT RT Subnet"
    Env = "QA"
  }
}

resource "aws_route_table_association" "PublicRTAssignA" {
  route_table_id = "${aws_route_table.PublicRT.id}"
  subnet_id = "${aws_subnet.PublicSubnetA.id}"
}

resource "aws_route_table_association" "PublicRTAssignB" {
  route_table_id = "${aws_route_table.PublicRT.id}"
  subnet_id = "${aws_subnet.PublicSubnetB.id}"
}

resource "aws_route_table_association" "PublicRTAssignC" {
  route_table_id = "${aws_route_table.PublicRT.id}"
  subnet_id = "${aws_subnet.PublicSubnetC.id}"
}

resource "aws_route_table_association" "NATRTAssignA" {
  route_table_id = "${aws_route_table.NATRT.id}"
  subnet_id = "${aws_subnet.PrivateSubnetA.id}"
}

resource "aws_route_table_association" "NATRTAssignB" {
  route_table_id = "${aws_route_table.NATRT.id}"
  subnet_id = "${aws_subnet.PrivateSubnetB.id}"
}

resource "aws_route_table_association" "NATRTAssignC" {
  route_table_id = "${aws_route_table.NATRT.id}"
  subnet_id = "${aws_subnet.PrivateSubnetC.id}"
}