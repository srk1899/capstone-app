terraform {
  backend "s3" {
    bucket         = "my-task-14-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
