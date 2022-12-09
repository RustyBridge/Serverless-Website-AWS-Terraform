# Define the Variable

variable "profile_d" {
  description = "Details of the AWS profile"
  #default = [{region = "us-east-1", name = "profile_name"}]
}

variable "bucket_names" {
  description = "Names of the buckets"
}

variable "iam_policy_arn" {
  description = "IAM policies to be attached to role for lamda"
  type = list(string)
}

variable "p_credentials" {
  description = "Path to the credentials file"
  type = list(string)
}