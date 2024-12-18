variable "vpc-name" {
  type = string
  description = "vpc name"
}

variable "cidr_block" {
  type = string
  description = "vpc cidr"
}

variable "availability_zones" {
  type = list(string)
  description = "availability zone of subnets"
}

variable "subnets_cidr" {
  type = list(string)
  description = "cidr range of my subnets"
}

variable "ports" {
  type = list(number)
  description = "ports opened on firewall"
}

variable "instance_type" {
  type = string
  description = "instance type for the ec2"
}

variable "instance_volume" {
  type = number
  description = "volume size attahced to the instance"
}

variable "pub-key" {
  type = string
  description = "public key"
}

variable "priv-key" {
  type = string
  description = "private key for the instance"
}

