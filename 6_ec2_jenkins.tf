# security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow HTTP, HTTPS, SSH to Jenkins"
  vpc_id      = aws_vpc.nti_vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-sg"
  }
}

# IAM Role for Jenkins EC2
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach CloudWatch Policy
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 instance for Jenkins
resource "aws_instance" "jenkins" {
  ami                    = "ami-096a2911074929e0b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public-us-east-2a.id
  key_name               = "jenkins_key"
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name  # ← الإضافة هنا

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "jenkins-instance"
  }
}
