provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2  = "http://host.docker.internal:4566"
    s3   = "http://host.docker.internal:4566"
    iam  = "http://host.docker.internal:4566"
    cloudformation = "http://host.docker.internal:4566"
  }
}
