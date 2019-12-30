# Provider AWS
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Cert Management
resource "aws_acm_certificate" "cert" {
  domain_name               = "michaelgoehle.com"
  subject_alternative_names = ["*.michaelgoehle.com"]
  validation_method         = "DNS"
}

# Route 53 Zone
resource "aws_route53_zone" "zone" {
  name = "michaelgoehle.com"
}

# Route 53 Records
resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id = aws_route53_zone.zone.id
  records = [
  aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
  ttl = 60
}

//resource "aws_route53_record" "cert_validation_alt1" {
////  name    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_name
////  type    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_type
////  zone_id = aws_route53_zone.zone.id
////  records = [
////  aws_acm_certificate.cert.domain_validation_options[1].resource_record_value]
////  ttl = 60
////}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn,
//    aws_route53_record.cert_validation_alt1.fqdn,
  ]
}

# S3 Buckets
resource "aws_s3_bucket" "content" {
  bucket = "podcast-content-bucket-name-example"
  acl    = "public-read"
}

resource "aws_s3_bucket" "rss" {
  bucket = "podcast-rss-bucket-name-example"
  acl    = "public-read"
  website {
    index_document = "podcast.xml"
  }
}

# S3 bucket policies
resource "aws_s3_bucket_policy" "content" {
  bucket = aws_s3_bucket.content.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::podcast-content-bucket-name-example/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::podcast-content-bucket-name_-example"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_policy" "rss" {
  bucket = aws_s3_bucket.rss.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::podcast-rss-bucket-name-example/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::podcast-rss-bucket-name-example"
        }
    ]
}
POLICY
}

# Role Mangement
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1577652794517",
      "Action": "iam:*",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    },
    {
      "Sid": "Stmt1577652907335",
      "Action": "iam:*",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    }
  ]
}
EOF
}

# Lambda function management
resource "aws_lambda_function" "podcast_xml_generator" {
  filename      = "mp3.py"
  function_name = "Podcast_Name_Example"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "mp3.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("mp3.py")

  runtime = "python3.7"

  environment {
    variables = {
      category_one          = "category 1"
      category_two          = "category 2"
      cloudfront_content    = "https://podcast-content-bucket-name-example.s3.amazonaws.com"
      copyright_text        = "sample copyright text"
      email                 = "example@example.com"
      explicit              = "no"
      language              = "en"
      podcast_author        = "sample author"
      podcast_des           = "sample description here"
      podcast_img_url       = "https://podcast-content-bucket-name-example.s3.amazonaws.com/image.jpeg"
      podcast_name          = "Sample Podcast Name Here"
      podcast_subtitle      = "sample subtitle"
      podcast_type          = "episodic"
      podcast_url           = "https://podcast-rss-bucket-name-example.s3.amazonaws.com"
      podcast_xml_file_name = "podcast.xml"
      s3_bucket_rss         = "podcast-rss-bucket-name-example"
      s3_bucket_trigger     = "podcast-content-bucket-name-example"
      sub_category_one      = ""
      sub_category_two      = ""
      website               = "http://example.com"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.content.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.podcast_xml_generator.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }
}

# Cloud front management
locals {
  s3_origin_id = "S3-Podcast"
}

resource "aws_cloudfront_distribution" "podcast_content" {
  origin {
    domain_name = aws_s3_bucket.content.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

//    s3_origin_config {
//      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
//    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "This distribution contains the mp3 and content for the podcast"
  default_root_object = "index.html"

//  logging_config {
//    include_cookies = false
//    bucket          = "mylogs.s3.amazonaws.com"
//    prefix          = "myprefix"
//  }

  aliases = ["podcastcontent.michaelgoehle.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"
  # Update locations later
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_distribution" "podcast_rss" {
  origin {
    domain_name = aws_s3_bucket.rss.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

//    s3_origin_config {
//      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
//    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Contains xml file to be shared with public directories like spotify, google podcasts, etc."
  default_root_object = "podcast.xml"

//  logging_config {
//    include_cookies = false
//    bucket          = "mylogs.s3.amazonaws.com"
//    prefix          = "myprefix"
//  }

  aliases = ["podcast.michaelgoehle.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"
  # Update locations later
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


# AWS route 53 A records
resource "aws_route53_record" "podcast" {
  zone_id = aws_route53_zone.zone.id
  name    = "podcast.michaelgoehle.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.podcast_rss.domain_name
    zone_id                = aws_cloudfront_distribution.podcast_rss.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "podcastcontent" {
  zone_id = aws_route53_zone.zone.id
  name    = "podcastcontent.micahelgoehle.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.podcast_content.domain_name
    zone_id                = aws_cloudfront_distribution.podcast_content.hosted_zone_id
    evaluate_target_health = false
  }
}

# SNS Topic subscription
resource "aws_sns_topic" "xml_generation_error" {
  name = "xml_generation_error"
}
# Create a subscriber for the topic unsure how to do this

# Cloud Watch Alarm
resource "aws_cloudwatch_metric_alarm" "podcast_xml_generation_error" {
  alarm_name                = "XML-Generation-Problem"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "360"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_actions = [aws_sns_topic.xml_generation_error.arn]
  alarm_description         = "This monitors issues with the xml file generating"
  actions_enabled           = true
}
