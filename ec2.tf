resource "aws_instance" "public_instance" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.medium"
  key_name                    = "THT"
  subnet_id                   = aws_subnet.public1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public.id]
  tags = {
    Name = "PublicMachine"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  provisioner "file" {
    source      = "./THT.pem"
    destination = "/home/ubuntu/THT.pem"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./THT.pem")
    }
  }
}

resource "aws_instance" "private_instance" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.medium"
  key_name                    = "THT"
  subnet_id                   = aws_subnet.private1.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private.id]
  tags = {
    Name = "PrivateMachine"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  provisioner "file" {
    source      = "./THT.pem"
    destination = "/home/ubuntu/THT.pem"

    connection {
      type        = "ssh"
      host        = aws_instance.public_instance.public_ip
      user        = "ubuntu"
      private_key = file("./THT.pem")
    }
  }
}

# Security Group Rules

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.this.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.this.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["10.100.0.0/16"]  # Allow SSH from VPC CIDR range
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  tags = {
    Name = "private-sg"
  }
}
