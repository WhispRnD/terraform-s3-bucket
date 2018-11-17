resource "aws_s3_bucket" "main" {
  bucket = "${var.domain}"

  cors_rule {
    allowed_headers = [
      "Authorization",
    ]

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    allowed_origins = [
      "*",
    ]

    max_age_seconds = 3000
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.domain}/*"
        }
    ]
}
EOF

  website {
    index_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
    },
    "Redirect": {
        "HostName": "${var.domain}",
        "ReplaceKeyPrefixWith": "#/"
    }
}]
EOF
  }
}

resource "aws_s3_bucket" "redirect" {
  bucket = "${var.www_domain}"
  count  = "${var.www_domain == "" ? 0 : 1}"

  website = {
    redirect_all_requests_to = "${var.domain}"
  }
}

resource "aws_route53_record" "main_route" {
  count   = "${var.route53_zone_id == "" ? 0 : 1}"
  zone_id = "${var.route53_zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    evaluate_target_health = false
    zone_id                = "${aws_s3_bucket.main.hosted_zone_id}"
    name                   = "${aws_s3_bucket.main.website_domain}"
  }
}

resource "aws_route53_record" "redirect_route" {
  count   = "${(var.route53_zone_id == "" || var.www_domain == "") ? 0 : 1}"
  zone_id = "${var.route53_zone_id}"
  name    = "${var.www_domain}"
  type    = "A"

  alias {
    evaluate_target_health = false
    zone_id                = "${aws_s3_bucket.redirect.hosted_zone_id}"
    name                   = "${aws_s3_bucket.redirect.website_domain}"
  }
}
