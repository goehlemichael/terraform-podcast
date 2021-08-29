# ---------------------------------------------------------------------------------------------------------------------
# OUTPUT VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
output "podcast_url" {
  value       = aws_lambda_function.podcast_xml_generator.environment[0].variables.podcast_url
  description = "This is the url to reach the rss feed for the podcast"
}

output "podcast_feed_cdn_url" {
  value       = aws_cloudfront_distribution.podcast_rss.domain_name
  description = "This is the url to reach the rss feed for the podcast"
}

output "content_bucket_url" {
  value = aws_cloudfront_distribution.podcast_content.domain_name
  description = "The s3 url for the content bucket, should not be accessible"
}

output "log_bucket_url" {
  value = aws_s3_bucket.logs.bucket_domain_name
  description = "The s3 url for the content bucket, should not be accessible"
}
