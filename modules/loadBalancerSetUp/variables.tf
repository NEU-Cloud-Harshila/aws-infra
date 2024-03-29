variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "record_creation_name" {
  type = string
}