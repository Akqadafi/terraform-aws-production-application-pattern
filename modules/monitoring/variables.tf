variable "name_prefix" { type = string }
variable "sns_email_endpoint" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}