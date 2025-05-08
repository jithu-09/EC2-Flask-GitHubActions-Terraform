resource "aws_instance" "ec2_instance" {
    #ubuntu ami 
    ami = "ami-0c55b159cbfafe1f0" # Replace with the latest Ubuntu AMI ID
    instance_type = "t2.medium" 
    subnet_id = aws_subnet.pub_subnet.id
    security_groups = [aws_security_group.docker_on_ec2.name]
    key_name = "ExtraKey" # Replace with your key pair name
    #script to install docker
    user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF
    #IAM role for EC2 instance
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    
    tags = {
        Name = "${var.prefix}-ec2-instance"
    }
}

resource "aws_ecr_repository" "flask" {
   name = "docker-flask"
}

resource "aws_security_group" "docker_on_ec2" {
  vpc_id = aws_vpc.vpc.id
  description = "Allow Docker on EC2"
  name = "docker_on_ec2"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
