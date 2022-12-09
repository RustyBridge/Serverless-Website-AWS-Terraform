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

# Configure the Providers
provider "aws" {
  region                  = var.profile_d[0].region
  shared_credentials_files = [var.p_credentials[0]]
  profile                 = var.profile_d[0].name
}

provider "archive" {

}

provider "local" {

}