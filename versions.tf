terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56.0"
    }
  }
  required_version = "~> 1.0.5"
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
//  profile = ""
}
