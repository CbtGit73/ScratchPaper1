output "cloudfront_endpoint" {
    value = "https://${aws_route53_record.www.name}"
}
