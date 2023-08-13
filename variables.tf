variable "function_name" {
  type = string
}

variable "allow_origins" {
  type = list(string)
}

variable "cors_anywhere_version" {
  type    = string
  default = "0.4.4"
}
