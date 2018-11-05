variable "name_prefix" {
  default                       = "terraform-project"
}

variable "environment" {
  default                       = "DEV"
}

variable "user" {
  default                       = "ec2-user"
}

variable "image_id" {
  default = {
	"back"			= ""
	"front"			= ""
  }
}

variable "instance_type" {
  default = {
	"back"			= ""
	"front"			= ""
  }
}

variable "key_name" {
  default			= ""
}
