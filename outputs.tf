# ---------------------------------------------------------------------------------------------------------------------
# OUTPUT VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
output "podcast_url" {
  value       = aws_lambda_function.podcast_xml_generator.environment[0].variables.podcast_url
  description = "This is the url to reach the rss feed for the podcast"
}
