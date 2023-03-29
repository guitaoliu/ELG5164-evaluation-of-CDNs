terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    gcp = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "gt-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
