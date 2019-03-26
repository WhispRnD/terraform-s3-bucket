resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}"

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

}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = "${aws_s3_bucket.bucket.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.name}/*"
        }
    ]
}
EOF
}
