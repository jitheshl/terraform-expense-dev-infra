terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63.0"
    }
    }
    backend "s3"{
        bucket = "jithesh-tf-remote-state-expense-dev"
        key = "sg-expense-dev-vpc" #we should have unique key with in the bucket, same key should not be used in other purpose 
        region = "us-east-1"
        dynamodb_table = "jithesh-state-locking-expense-dev"
    }

}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}