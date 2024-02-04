#1 Provider for he SSL cert to be created in us-east-1
provider "aws" {
  alias = "acm"
  region = "us-east-1"
  version = "5.0"
}

#2 Create SSL Certificate with variables
resource "aws_acm_certificate" "acm_domain" {
  provider = "aws.acm"
  domain_name = "${var.domain}"
  subject_alternative_names = ["*.${var.domain}"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

/*
data "aws_route53_zone" "selected" {
  name         = "test.com."
private_zone = false
}
*/

#3 Validate SSL Certificate
resource "aws_route53_record" "validation" {
  zone_id = "${aws_route53_zone.public_zone.zone_id}"
  name = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.default.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl = "300"
}

#4 Finishes Validation
resource "aws_acm_certificate_validation" "default" {
  provider = "aws.acm"
  certificate_arn = "${aws_acm_certificate.default.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

