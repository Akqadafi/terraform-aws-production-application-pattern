variable "name_prefix" { type = string }
variable "public_subnet_id" { type = string }
variable "ec2_security_group_id" { type = string }
variable "ec2_instance_type" { type = string }

variable "ami_ssm_parameter_name" { type = string }

# Default keeps your original behavior but expects 1a_user_data.sh inside this module folder.
variable "user_data_file" {
  type    = string
  default = "1a_user_data.sh"
}

variable "tags" {
  type    = map(string)
  default = {}
}