resource "aws_s3_bucket" "testbucket1-00" {
  bucket = "my-tf-test-bucket-bashiir"  # name of bucket
  acl    = "private"

  tags = {
    Name = "bucket-311"
  }
}
