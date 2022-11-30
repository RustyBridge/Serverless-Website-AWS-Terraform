terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3" 
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}
