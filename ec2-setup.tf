provider "aws" {
  
}

resource "aws_instance" "test" {
  ami = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id] #Attaching "my-sg" security groups to ec2 instance
  subnet_id = aws_subnet.public-subnet.id #Attaching VPC to the instance
  key_name = "terraform" #Attaching key pair to the instance

  tags = {
    Name = "test-ec2"
  }
}

resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
  description = "create a security group"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_outbound" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-rt-association" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_eip" "elastic-ip" {
  domain = "vpc"

  tags = {
    Name = "test-elastic-ip"
  }
}

resource "aws_eip_association" "eip-association" {
  instance_id = aws_instance.test.id
  allocation_id = aws_eip.elastic-ip.id
}

resource "aws_key_pair" "terraform" {
  key_name = "ansible"
  public_key = file(""C:/Users/devop/OneDrive/Desktop/ansible.pem"")
}

resource "aws_ebs_volume" "ec2-vol" {
  availability_zone = "ap-south-1a"
  size = 25

  tags = {
    Name = "ec2-volume"
  }
}

resource "aws_volume_attachment" "ec2-vol-attach" {
  volume_id = aws_ebs_volume.ec2-vol.id
  instance_id = aws_instance.test.id
  device_name = "/dev/sdh"
}

