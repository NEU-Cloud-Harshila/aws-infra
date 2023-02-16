variable "cidr_block" {
  type = string
}

variable "instance_tenancy" {
  type = string
}

variable "internet_gateway_name" {
  type = string
}


variable "public_subnet_name" {
  type = string
}

variable "subnet_count" {
  type = number
}

variable "bits" {
  type = number
}

variable "vpc_resource_name" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "private_routetable_name" {
  type = string
}

variable "public_routetable_name" {
  type = string
}