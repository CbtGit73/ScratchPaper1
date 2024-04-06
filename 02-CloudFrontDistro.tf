# Holds values that are repeated throughout the code
locals { 
    s3_origin_id = "${random_string.random.result}-origin"
    hosted_zone_id = "Z091687013GGJBC7OUC98"
    my_domain = "ninjasdelacloud.com"
    acm_arn = "arn:aws:acm:us-east-1:107881574243:certificate/a8336b75-dee8-45d1-950a-919f66821abd"
}

#Origin access
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = aws_s3_bucket.bucket.bucket_regional_domain_name
  description                       = "${random_string.random.result}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" { 
    origin {
        domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
        origin_id                = local.s3_origin_id
    }

    enabled = true
    is_ipv6_enabled = false
    comment = "S3 bucket distribution"
    default_root_object = "index.html"

    default_cache_behavior {
        compress = true
        viewer_protocol_policy = "allow-all"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        
        target_origin_id = local.s3_origin_id
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }

        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"          
        }
    }

    price_class = "PriceClass_100"

    tags = {
        Environment = "development"
    }

    viewer_certificate {
        cloudfront_default_certificate = true
        acm_certificate_arn = local.acm_arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }
}


aws ec2 run-instances --image-id ami-0900fe555666598a2 --count 1 --instance-type t2.micro --iam-instance-profile Name=document-access-instance-profile --key-name us-east-2-key2.pem
