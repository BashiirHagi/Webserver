# // Create a VPC
# // Create a Internet gateway 
# // Create a custom route table
# // Create a subnet
# // Associate subnet with route table
# // Create a security group to allow SSH, HTTPS, HTTPS traffic
# // Create a network interface with an IP in the subnet created in step 4 
# // Assign a elastic IP address to the network interface created in step 7 
# // Create a Ubuntu server and install apache2 webserver


resource "aws_vpc" "MyVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Production"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.MyVpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "prod_table" {
  vpc_id = aws_vpc.MyVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.MyVpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "Production_subnet"
  }
}
# associating a subnet with the route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.prod_table.id
}

resource "aws_security_group" "my_sg" {
  name   = "allow_rules"
  vpc_id = aws_vpc.MyVpc.id

  // port numbers 22, 80, 443

  ingress { //inbound traffic 
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { //inbound traffic 
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { //inbound traffic 
    description = "SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { //outbound traffic 
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.my_sg.id]

}

resource "aws_eip" "elastic_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
}

resource "aws_instance" "LinuxServers" {
  ami               = "ami-0fb653ca2d3203ac1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  key_name          = "Terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server.id 
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo This is my webserver > /var/www/html/index.html'
              EOF
tags = {
  Name = "web-server"
}
}
