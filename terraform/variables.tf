variable "app_name" {
  default = "capstone-app"
}

variable "region" {
  default = "us-east-1"
}

variable "image_tag" {
  description = "The image tag for the Docker image"
  type        = string
}
