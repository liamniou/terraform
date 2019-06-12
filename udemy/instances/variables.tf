variable "region" {
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "remote_state_bucket" {
  description = "Bucket name for layer 1 remote state"
}

variable "remote_state_key" {
  description = "Key name for layer 1 remote state"
}

variable "ec2_instance_type" {
  description = "EC2 Instance type to launch"
}

variable "key_pair_name" {
  default     = "myEC2KeyPair"
  description = "Keypair to use to connecto to EC2 Instances"
}

variable "max_instance_size" {
  description = "Maximum number of instances to launch"
}

variable "min_instance_size" {
  description = "Minimum number of instances to launch"
}