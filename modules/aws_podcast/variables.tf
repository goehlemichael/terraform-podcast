variable "domain_name" {
  type        = string
  description = "The root domain of the podcast i.e. example.com as a relative URL"
}
variable "content_domain_name" {
  type        = string
  description = "The subdomain for media, i.e. podcastcontent.example.com as a relative url"
}
variable "log_bucket_name" {
  type        = string
  description = "The bucket for logs"
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
    condition     = length(var.podcast_description) <= 4000
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
