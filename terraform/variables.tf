variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1" 
}
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-04f3a18c014b1a9ed"
}
variable "public_subnets" {
  type = list(string)
  default = ["subnet-06e38cb617dbb2aa4",
  "subnet-05f8afe001ad1ae65"
]
  
}
variable "alb_sg" {
  description = "Security group for the Application Load Balancer"
  type        = string
  default     = "sg-008707b90399f228d"
}
variable "ecs_sg" {
  description = "Security group for the Application Load Balancer"
  type        = string
  default     = "sg-0d65600f7ae16c2af"

}
variable "ecs_task_exec_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
  default     = "arn:aws:iam::970244359411:role/ecsTaskExecutionRole"
}

variable "image_tag" {
  description = "The Docker image tag to use for the ECS task"
  type        = string
}


