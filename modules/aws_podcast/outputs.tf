output "podcast_url" {
  value       = aws_lambda_function.podcast_xml_generator.environment[0].variables.podcast_url
  description = "url to reach the rss feed for the podcast"
}

output "podcast_feed_cdn_url" {
  value       = aws_cloudfront_distribution.podcast_rss.domain_name
  description = "url to reach the rss feed for the podcast"
}

output "content_bucket_url" {
  value       = aws_s3_bucket.content.bucket_domain_name
  description = "only root url should be accessible"
}

output "content_bucket_name" {
  value       = aws_s3_bucket.content.bucket
  description = "for testing bucket"
}

output "log_bucket_url" {
  value       = aws_s3_bucket.logs.bucket_domain_name
  description = "The s3 url for the content bucket, should not be accessible"
}

output "content_cdn_url" {
  value       = aws_cloudfront_distribution.podcast_content.domain_name
  description = "The s3 url for the content bucket, should not be accessible"
}

output "lambda_name" {
  value       = aws_lambda_function.podcast_xml_generator.function_name
  description = "The name of the lambda function"
}

output "region" {
  value = data.aws_region.current.name
}