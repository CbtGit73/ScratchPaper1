#1 S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "psychoticbumpschool"
}

#2 Object ownership controls are owner enforced
resource "aws_s3_bucket_ownership_controls" "S3controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#3 public access is blocked on all fronts
resource "aws_s3_bucket_public_access_block" "pabs" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket Versioning is disabled
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

#4 ACL settings depend on Object Controls and Public Access Controls
# ACL is private
resource "aws_s3_bucket_acl" "S3ACL" {
  depends_on = [
    aws_s3_bucket_ownership_controls.S3controls,
    aws_s3_bucket_public_access_block.pabs,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

#bucket objects
resource "aws_s3_object" "ninjafile" {
  for_each     = var.objects
  bucket       = aws_s3_bucket.bucket.id
  key          = each.key
  source       = "./Content/${each.key}"
  content_type = each.value
  #etag         = filemd5(each.value)
  acl = "public-read"
}

/*
#Policy to make picture show
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.arn}/*"
        }
      ]
    }
  )
}
*/

/*
# Variable s# Bucket******
module "s3" {

    source = "</Users/christopher/Cloud_Ninjas_Pics_Gifs/Pics_Gifs>"

    bucket_name = "Pics_Gifs"       

}

resource "aws_s3_bucket" "buckets" {

    bucket = "${var.bucket_name}" 

    acl = "${var.acl_value}"
*/
