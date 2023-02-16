variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Default region closer to the user"
}

variable "environment" {
  default     = "demo"
  type        = string
  description = "AWS environment demo or dev"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type    = string
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "subnet_count" {
  default = 3
}

variable "subnet_bits" {
  default = 8
}

variable "vpc_resource_name" {
  default = "vpc1"
}

variable "vpc_internet_gateway_name" {
  default = "IGWvpc1"
}

variable "vpc_public_subnet_name" {
  default = "PublicSubnetvpc1"
}

variable "vpc_public_routetable_name" {
  default = "PublicRouteTablevpc1"
}

variable "vpc_private_subnet_name" {
  default = "PrivateSubnetvpc1"
}

variable "vpc_private_routetable_name" {
  default = "PrivateRouteTablevpc1"
}