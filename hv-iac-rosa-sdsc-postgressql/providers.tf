terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.3"
    }
    local = {
      source = "hashicorp/local"
      version = ">= 2.2.0"
    }
  }
}
    


provider "aws" {
  region = var.aws_region

  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

provider "rhcs" {
  token = var.token
}

