terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0"
    }
  }
  required_version = ">= 1.0"
}

## Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
      profile = "mike"
}
