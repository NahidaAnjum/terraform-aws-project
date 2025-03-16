terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #you can also provide the access keys here for aws which is not recommended but yeah you can use this block to do so 
  # I configured using aws configure in my project
}