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

#key_pairs
resource "aws_key_pair" "key_pair" {
  key_name   = "jekins-key"
  public_key = file(var.pub-key)
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  subnet_id = aws_subnet.pub-subnet[0].id
  vpc_security_group_ids = [aws_security_group.jenkins-sg11.id]

  tags = {
    Name = "Jenkins-server"
  }
}