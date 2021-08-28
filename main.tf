# ---------------------------------------------------------------------------------------------------------------------
# Set Infrastructure Variables - Domain Name, Content Sub Domain, Podcast RSS Sub Domain, etc.
# ---------------------------------------------------------------------------------------------------------------------
variable "domain_name" {
  type        = string
  description = "The root domain of the podcast i.e. example.com as a relative URL"
}
variable "content_domain_name" {
  type        = string
  description = "The subdomain for media, i.e. podcastcontent.example.com as a relative url"
}
variable "rss_domain_name" {
  type        = string
  description = "The subdomain for the rss feed i.e. podcast.example.com"
}
variable "rss_bucket_name" {
  type        = string
  description = "The name of the bucket the rss feed will be served from i.e. rss-bucket-name-here"
}
variable "content_bucket_name" {
  type        = string
  description = "The name of the bucket the content will be served from i.e. content-bucket-name-here"
}
# ---------------------------------------------------------------------------------------------------------------------
# Set Podcast Variables - Podcast name, author, email, description, etc.
# ---------------------------------------------------------------------------------------------------------------------
variable "podcast_name" {
  type        = string
  description = "The name of the podcast"
}
variable "podcast_subtitle" {
  type        = string
  description = "The subtitle of the podcast"
}
variable "podcast_description" {
  type        = string
  description = "The description of the podcast. 4000 byte limit."
  validation {
    condition = length(var.podcast_description) <= 4000
    error_message = "Description text is greater than 4000 bytes."
  }
}
variable "podcast_author" {
  type        = string
  description = "The author of the podcast"
}
variable "podcast_email" {
  type        = string
  description = "Valid email for author, RFC-5322"
}
variable "podcast_language" {
  type        = string
  description = "the language of the podcast ISO-639-1"
//  validation {
//    condition = can(regex("",) var.podcast_email)
//    error_message = "Not a valid URL"
//  }
}
variable "category_one" {
  type        = string
  description = "The category This is a standard list i.e. Technology "
}
variable "category_two" {
  type        = string
  description = "A second category this is from a standard list i.e. Technology"
}
variable "subcategory_one" {
  type        = string
  description = "The subcategory this comes from a standard list i.e. Technology"
}
variable "subcategory_two" {
  type        = string
  description = "A second subcategory this comes from a standard list i.e. Technology"
}
variable "podcast_type" {
  type        = string
  description = "This is either episodic or series"
}
variable "copyright_text" {
  type        = string
  description = "The text that will go in the copyright tag on the rss feed"
}
variable "explicit" {
  type        = string
  description = "This is required for some platforms if the podcast contains explicit content"
}
# ---------------------------------------------------------------------------------------------------------------------
# Set Variables for TF Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "podcast_file_name" {
  type        = string
  description = "The filename for the xml file which defines the podcast rss feed"
}
# ---------------------------------------------------------------------------------------------------------------------
# GET AMAZON CERTIFICATE FOR THE GIVEN DOMAIN NAME
# ---------------------------------------------------------------------------------------------------------------------
# Find a certificate issued by ACM (not imported cert)
data "aws_acm_certificate" "cert" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
# Route 53 Zone
data "aws_route53_zone" "zone" {
  name = var.domain_name
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE SNS TOPIC FOR PODCAST ERRORS RESULTING FROM THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_sns_topic" "podcast-errors" {
  name = "podcast-errors"
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE SNS TOPIC POLICY FOR PODCAST ERRORS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.podcast-errors.arn
  policy = data.aws_iam_policy_document.sns-topic-policy.json
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"
    resources = [aws_sns_topic.podcast-errors.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
//        "${var.default}",
      ]
    }
  }
//  statement {
//    sid = "2"
//
//    actions = ["SNS:Publish"]
//    effect = "Allow"
//    resources = [aws_cloudwatch_metric_alarm.podcast_xml_generation_error.arn]
//
//    principals {
//      identifiers = ["events.amazonaws.com"]
//      type = "Service"
//    }
//    condition {
//      test = "StringEquals"
//      values = [
////        ""
//      ]
//      variable = "AWS:SourceOwner"
//    }
//  }
}

# Create a subscriber for the topic
# ---------------------------------------------------------------------------------------------------------------------
# CREATE S3 BUCKETS FOR THE CONTENT & THE RSS FEED
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "content" {
  bucket = var.content_bucket_name
  acl    = "public-read"
//  region = "us-east-1"
}

resource "aws_s3_bucket" "rss" {
  bucket = var.rss_bucket_name
  acl    = "public-read"
//  region = "us-east-1"
  website {
    index_document = var.podcast_file_name
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE S3 BUCKET POLICY NEED TO UPDATE
# ---------------------------------------------------------------------------------------------------------------------
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
            "Resource": "arn:aws:s3:::${var.content_bucket_name}/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${var.content_bucket_name}"
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
            "Resource": "arn:aws:s3:::${var.rss_bucket_name}/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${var.rss_bucket_name}"
        }
    ]
}
POLICY
}
# ---------------------------------------------------------------------------------------------------------------------
# UPLOAD S3 BUCKET OBJECTS TO CONTENT BUCKET - GENERATES MINIMUM OBJECTS TO CREATE AN EXAMPLE PODCAST
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "podcast_image" {
  bucket = aws_s3_bucket.content.id
  key    = "image.jpeg"
  source = "./podcast_example/main_image.jpeg"
  content_type = "image/jpeg"
}
resource "aws_s3_bucket_object" "episode" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/episode1.mp3"
  source = "./podcast_example/episodeexample.mp3"
  content_type = "audio/mp3"
}
resource "aws_s3_bucket_object" "episode_image" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/image.jpeg"
  source = "./podcast_example/episode_image.jpeg"
  content_type = "image/jpeg"
}
resource "aws_s3_bucket_object" "episode_title" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/title.txt"
  source = "./podcast_example/title.txt"
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "episode_description" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/description.txt"
  source = "./podcast_example/description.txt"
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "episode_duration" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/duration.txt"
  source = "./podcast_example/duration.txt"
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "episode_pubdate" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/pubdate.txt"
  source = "./podcast_example/pubdate.txt"
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "episode_explicit" {
  bucket = aws_s3_bucket.content.id
  key    = "episode1/explicit.txt"
  source = "./podcast_example/explicit.txt"
  content_type = "text/plain"
}
# ---------------------------------------------------------------------------------------------------------------------
# UPLOAD S3 BUCKET OBJECTS RSS BUCKET - This is to remove the object after teardown
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "podcast_rss" {
  bucket = aws_s3_bucket.rss.id
  key    = var.podcast_file_name
  source = "./podcast_example/${var.podcast_file_name}"
  content_type = "application/xml"
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLE FOR LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# ---------------------------------------------------------------------------------------------------------------------
# ALLOW
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda-s3-trigger" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "lambda-cloudwatch" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
resource "aws_iam_role_policy_attachment" "cloudwatch-logging" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "sns-publish" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
# ---------------------------------------------------------------------------------------------------------------------
# ALLOW S3 BUCKET TO INVOKE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.podcast_xml_generator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.content.arn
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE LAMBDA FUNCTION TO GENERATE XML FOR RSS FEED
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "podcast_xml_generator" {
  filename      = "podcast.py.zip"
  function_name = "Podcast_Name_Example"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "podcast.handler"
  runtime       = "python3.7"
  timeout       = "60"

  environment {
    variables = {
      category_one          = var.category_one
      category_two          = var.category_two
      cloudfront_content    = "https://${var.content_domain_name}/"
      copyright_text        = var.copyright_text
      email                 = var.podcast_email
      explicit              = var.explicit
      language              = var.podcast_language
      podcast_author        = var.podcast_author
      podcast_desc          = var.podcast_description
      podcast_img_url       = "https://${var.content_domain_name}/image.jpeg"
      podcast_name          = var.podcast_name
      podcast_subtitle      = var.podcast_subtitle
      podcast_type          = var.podcast_type
      podcast_url           = "https://${var.rss_domain_name}/"
      podcast_xml_file_name = var.podcast_file_name
      s3_bucket_rss         = var.rss_bucket_name
      s3_bucket_trigger     = var.content_bucket_name
      sub_category_one      = var.subcategory_one
      sub_category_two      = var.subcategory_two
      website               = "http://${var.domain_name}"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.content.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.podcast_xml_generator.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLOUDFRONT DISTRIBUTIONS FOR PODCAST CONTENT & RSS FEED
# ---------------------------------------------------------------------------------------------------------------------
locals {
  s3_origin_id = "S3-Podcast"
}

resource "aws_cloudfront_distribution" "podcast_content" {
  origin {
    domain_name = aws_s3_bucket.content.bucket_regional_domain_name
    custom_header {
      name = "Accept-Ranges"
      value = "bytes"
    }
    origin_id   = local.s3_origin_id

//    s3_origin_config {
//      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
//    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "This distribution serves the media for the podcast"
//  default_root_object = "index.html"

//  logging_config {
//    include_cookies = false
//    bucket          = "mylogs.s3.amazonaws.com"
//    prefix          = "myprefix"
//  }

  aliases = [var.content_domain_name]

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

  price_class = "PriceClass_200"
  # Update locations later
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_distribution" "podcast_rss" {
  origin {
    domain_name = aws_s3_bucket.rss.bucket_regional_domain_name
    custom_header {
      name = "Accept-Ranges"
      value = "bytes"
    }
    origin_id   = local.s3_origin_id

//    s3_origin_config {
//      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
//    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Contains xml file to be shared with public directories like spotify, google podcasts, etc."
  default_root_object = var.podcast_file_name

//  logging_config {
//    include_cookies = false
//    bucket          = "mylogs.s3.amazonaws.com"
//    prefix          = "myprefix"
//  }

  aliases = [var.rss_domain_name]

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

  price_class = "PriceClass_200"
  # Update locations
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLOUDWATCH ALARM FOR LAMBDA FUNCTION ERRORS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "podcast_xml_generation_error" {
  alarm_name                = "XML-Generation-Problem"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_actions             = [aws_sns_topic.podcast-errors.arn]
  ok_actions                = [aws_sns_topic.podcast-errors.arn]
  alarm_description         = "This monitors issues with the xml file generating"
  actions_enabled           = true

  dimensions = {
    FunctionName = aws_lambda_function.podcast_xml_generator.function_name
    Resource     = aws_lambda_function.podcast_xml_generator.function_name
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A RECORD FOR RSS FEED ENDPOINT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "podcast" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.rss_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.podcast_rss.domain_name
    zone_id                = aws_cloudfront_distribution.podcast_rss.hosted_zone_id
    evaluate_target_health = false
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A RECORD FOR PODCAST CONTENT ENDPOINT
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "podcastcontent" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.content_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.podcast_content.domain_name
    zone_id                = aws_cloudfront_distribution.podcast_content.hosted_zone_id
    evaluate_target_health = false
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE ZIP OF LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------
data "archive_file" "podcast_lambda" {
  type        = "zip"
  source_file = "podcast.py"
  output_path = "podcast.py.zip"
}