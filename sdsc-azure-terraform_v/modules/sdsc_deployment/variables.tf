variable "resource_group_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "template_file" {
  type = string
}

variable "parameters_json" {
  type      = string
  sensitive = true
}