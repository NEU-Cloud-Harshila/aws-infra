variable "username" {
  type = string
}

variable "identifier" {
  type = string
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "password" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "security_group_id" {
  type = string
}