terraform {
  backend "s3" {
    key            = "foundation/06-shared-services/terraform.tfstate"
    bucket         = "rj-landing-zone-tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rj-landing-zone-tflock"
    encrypt        = true
  }
}
