variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "environment" {
  default = "demo"
}

variable "subnet_bits" {
  default = 8
}

variable "zone_id" {
  type = string
}

variable "record_creation_name" {
  type = string
}

variable "subnet_count" {
  default = 3
}

variable "vpc_name" {
  default = "vpc-1"
}

variable "vpc_public_rt_name" {
  default = "vpc1-Public-RT"
}

variable "vpc_private_subnet_name" {
  default = "vpc1-Private-Subnet"
}

variable "vpc_private_rt_name" {
  default = "vpc1-Private-RT"
}

variable "vpc_internet_gateway_name" {
  default = "vpc1-IGate"
}

variable "vpc_public_subnet_name" {
  default = "vpc1-Public-Subnet"
}

variable "ami_key_pair_name" {
  default = "ec2-demo"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = 50
}

variable "app_port" {
  default = 3000
}

variable "username" {
  default = "csye6225"
}

variable "identifier" {
  default = "csye6225"
}

variable "db_name" {
  default = "csye6225"
}

variable "password" {
  default = "hello12345"
}

variable "engine_version" {
  default = "8.0"
}

variable "db_port" {
  default = 3306
}