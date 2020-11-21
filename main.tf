provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.2.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.2.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet"
  }

}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gw"
  }
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
    
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "my_sg" {
  name        = "allow_all_traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0deae60d2ac515b3c"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.my_sg.id ]
  subnet_id = aws_subnet.my_subnet.id
  key_name = "myUSE1KP"
  tags = {
    Name = "my_ec2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -p 80:80 tutum/hello-world"
    ]
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = self.public_ip
      private_key = file("~/Desktop/task2/myUSE1KP.pem")
    }

}
}