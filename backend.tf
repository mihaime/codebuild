terraform {
  backend "s3" {
    bucket = "codebuild-tf-state"
    key    = "terraform.tfstate
    region = "eu-west-3"
    encrypt = "true"
    kms_key_id = "arn:aws:kms:eu-west-3:234572319512:key/1ea698ac-81e8-4a57-ac62-224e3b547cdb"
  }
}
