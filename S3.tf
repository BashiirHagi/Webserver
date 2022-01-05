resource "aws_s3_bucket" "testbucket1-00" {
  bucket = "my-tf-test-bucket-bashiir" # name of bucket
  acl    = "private"

  tags = {
    Name = "bucket-311"
  }
}

//resource "aws_s3_bucket" "b" {
// bucket = "s3-website-test.hashicorp.com"
// acl    = "public-read"
//policy = file("policy.json")

//website {
//index_document = "index.html"
//error_document = "tech.jpeg"

//routing_rules = <<EOF
//[{
//"Condition": {
//"KeyPrefixEquals": "docs/"
//},
//"Redirect": {
// "ReplaceKeyPrefixWith": "documents/"
//}
//}]
//EOF
//}
//}