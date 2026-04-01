terraform {
  backend "s3" {
    bucket         = "rj-landing-zone-tfstate"
    key            = "foundation/04-logging/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rj-landing-zone-tflock"
    encrypt        = true
  }
}
