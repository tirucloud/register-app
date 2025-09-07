variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for CD Server EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for CD Server EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for CD Server EC2 instance"
  type        = string
}
