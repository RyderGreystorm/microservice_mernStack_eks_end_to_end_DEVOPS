resource "aws_vpc" "jenkins-vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support =  true
}

#Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.jenkins-vpc.id

  tags = {
    Name = "${var.vpc-name}-igw"
  }
}

#Subnets
resource "aws_subnet" "pub-subnet" {
  count = length(var.subnets_cidr)
  vpc_id     = aws_vpc.jenkins-vpc.id
  cidr_block = element(var.subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc-name}-subent${count.index}"
  }
}

#Route Table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.jenkins-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.vpc-name}-gw"
  }
}

#Route Table association
resource "aws_route_table_association" "pub-sub-rt-assoc" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.pub-subnet[count.index].id
  route_table_id = aws_route_table.pub-rt.id
}


#Security Group
resource "aws_security_group" "jenkins-sg11" {
  name = "${var.vpc-name}-sg"
  description = "open necessary ports for the jenkins server"
  vpc_id = aws_vpc.jenkins-vpc.id
  
  ingress = [
    for port in var.ports : {
        description = "TLS "
        from_port = port
        to_port = port
        protocol = "tcp"
        ivp6_cidr_blocks = ["::0/"]
        self = false
        prefix_list_ids = []
        security_groups = []
        cidr_blocks = ["0.0.0.0/0"]
    }

  ]
  egress {
    description = "egrss"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self = false
    prefix_list_ids = []
    security_groups = []
  }
}