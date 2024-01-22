module "s3" {

    source = "</Users/christopher/Cloud_Ninjas_Pics_Gifs/Pics_Gifs>"

    bucket_name = "Pics_Gifs"       

}

resource "aws_s3_bucket" "buckets" {

    bucket = "${var.bucket_name}" 

    acl = "${var.acl_value}"


#or


resource "aws_s3_bucket" "S3-bucket1" {
  bucket = "CloudNinjaInspirationPics&Gifs"

  tags = {
    Name        = "CloudNinjaInspirationPics&Gifs"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_ownership_controls" "object-ownership" {
  bucket = aws_s3_bucket.CloudNinjaInspirationPics&Gifs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public-access-settings" {
  bucket = aws_s3_bucket.CloudNinjaInspirationPics&Gifs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl-settings" {
  depends_on = [
    aws_s3_bucket_ownership_controls.CloudNinjaInspirationPics&Gifs,
    aws_s3_bucket_public_access_block.CloudNinjaInspirationPics&Gifs,
  ]

  bucket = aws_s3_bucket.CloudNinjaInspirationPics&Gifs.id
  acl    = "public-read"
}

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
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
        }
      ]
    }
  )
}
