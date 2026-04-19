data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2-key"
  public_key = tls_private_key.ec2.public_key_openssh
}


resource "aws_instance" "instance" {
  count         = length(var.subnet_ids)
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  subnet_id     = var.subnet_ids[count.index]
  user_data = templatefile("${path.module}/user_data.sh", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_host     = var.db_host       # e.g. "main-rds.xxxx.us-east-1.rds.amazonaws.com:3306"
  })
  associate_public_ip_address = false
  tags = {
    Name = "${var.prefix}-instance-${count.index + 1}"

  }

  root_block_device {
    volume_size = 20   # GB (default is usually 8 GB for Ubuntu)
    volume_type = "gp3"
  }
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = aws_key_pair.ec2.key_name
}
resource "aws_security_group" "ec2" {
  name        = "${var.prefix}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # private only, adjust as needed
  }
  ingress {
    description = "SSH"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # private only, adjust as needed
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-ec2-sg"
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.ec2.private_key_pem
  filename        = "${path.module}/../../keys/ec2-key.pem"
  file_permission = "0600"                                  # ← chmod 600 automatically
}

output "instance_ids" {
  value = aws_instance.instance[*].id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2.id
}