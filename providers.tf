# Configure the AWS Provider
provider "aws" {
  region                  = var.profile_d[0].region
  shared_credentials_files = [var.p_credentials[0]]
  profile                 = var.profile_d[0].name
}

provider "archive" {

}

provider "local" {

}