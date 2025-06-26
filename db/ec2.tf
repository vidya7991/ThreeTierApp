
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-09e6f87a47903347c"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_a.id
  key_name      = "learning001"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              echo '<!DOCTYPE html><html><body><h1>Login</h1><form><input type="text"/><input type="password"/><button>Login</button></form></body></html>' > /usr/share/nginx/html/index.html
              EOF
}

resource "aws_instance" "backend" {
  ami           = "ami-09e6f87a47903347c"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_b.id
  key_name      = "learning001"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 449752443649.dkr.ecr.us-east-1.amazonaws.com/flask-login:latest
              EOF
}
