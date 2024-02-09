#1 generates random alphanumeric values thst can be added to expressions/names to maintain uniqueness/limit redundancy
resource "random_string" "random" { 
    length = 6
    special = false 
    upper = false 
}

#2 S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "psychoticbumpschool${random_string.random.result}"
}

#3 Object ownership controls are owner enforced
resource "aws_s3_bucket_ownership_controls" "S3controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#4 public access is blocked on all fronts
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

#5 ACL settings depend on Object Controls and Public Access Controls
# ACL is private
resource "aws_s3_bucket_acl" "S3ACL" {
  depends_on = [
    aws_s3_bucket_ownership_controls.S3controls,
    aws_s3_bucket_public_access_block.pabs,
  ]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

# 6 bucket objects
resource "aws_s3_object" "ninjafile" {
  for_each     = var.objects
  bucket       = aws_s3_bucket.bucket.id
  key          = each.key
  source       = "./Content/${each.key}"
  content_type = each.value
  etag         = filemd5(each.value)
  acl = "private"
}

# 7 Encryption type
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    bucket_key_enabled = true
  }
}

# 8 Policy from CloudFront Data block
data "aws_iam_policy_document" "s3_policy_data" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = ["${aws_cloudfront_distribution.s3_distribution.arn}"]
    }
  }
}

# 9 Policy from CloudFront Resource block
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_policy_data.json
}
