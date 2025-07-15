terraform {
  backend "s3" {
    bucket         = "task-12bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
