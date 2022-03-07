output "podcast_url" {
  value       = module.aws_podcast.podcast_url
  description = "url to reach the rss feed for the podcast"
}

output "podcast_feed_cdn_url" {
  value       = module.aws_podcast.podcast_feed_cdn_url
  description = "url to reach the rss feed for the podcast"
}

output "content_bucket_url" {
  value       = module.aws_podcast.content_bucket_url
  description = "only root url should be accessible"
}

output "rss_bucket_url" {
  value = module.aws_podcast.podcast_url
  description = "url to the rss bucket"
}

output "content_bucket_name" {
  value       = module.aws_podcast.content_bucket_name
  description = "for testing bucket"
}

output "log_bucket_url" {
  value       = module.aws_podcast.log_bucket_url
  description = "The s3 url for the content bucket, should not be accessible"
}

output "content_cdn_url" {
  value       = module.aws_podcast.content_cdn_url
  description = "The s3 url for the content bucket, should not be accessible"
}

output "lambda_name" {
  value       = module.aws_podcast.lambda_name
  description = "The name of the lambda function"
}

output "xml_file_name" {
  value = var.podcast_file_name
  description = "name of the xml file that points to the rss feed"
}

output "region" {
  value = module.aws_podcast.region
}
