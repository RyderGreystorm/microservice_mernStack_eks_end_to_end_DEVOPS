module "jenkins" {
  source             = "../modules"
  availability_zones = var.availability_zones
  instance_volume    = var.instance_volume
  instance_type      = var.instance_type
  subnets_cidr       = var.subnets_cidr
  priv-key           = var.priv-key
  pub-key            = var.pub-key
  ports              = var.ports
  vpc-name           = var.vpc-name
  cidr_block         = var.cidr_block
}