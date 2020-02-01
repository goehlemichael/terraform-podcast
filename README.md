# terraform-podcast
terraform script for provisioning infrastructure to host your own podcast

![Topology](podcast.jpeg)

# Setup

1) You need a domain name
2) $ export TF_VAR_domain_name=example.com
3) $ terraform apply

# Using Infrastructure
1) Record/Edit your podcast episode
2) Inside the content bucket upload a file named image.jpeg = the podcast image (3000x3000px)
3) Create folder in content bucket - name it anything, just no spaces
4) Inside that same folder upload an mp3 for the episode - name it anything, just no spaces
5) Inside that same folder upload an image named image.jpeg = the episode image (3000x3000px with 72dpi)
6) Inside that same folder upload 
 - a file named title.txt = containing the name of the episode
 - a file named description.txt = containing the episode description
 - a file named pubDate.txt = containing the date the episode was published in RFC822 date format
 - a file named duration.txt = the duration of the episode in seconds


# Run Tests
    cd tests; go test -timeout 45m | tee test_output.log

To definitely do:
1) ensure no public access to bucket (cloudfront to bucket only)
2) certs terraform
3) lambda cloudwatch alarm is not able to publish to the sns topic
4) create cloudfront alarm for bytes downloaded in the content bucket
5) create a new sns topic for that cloudfront alarm
6) generate a subscriber when script is executed
7) create module for everything
8) more logging
9) tests: rss feed test, xml validation, content/rss buckets can't be reached publicly,
subscriber can subscriber to topic, lambda function fail notification, tls is working

improvement ideas: dynamo db store creation/upload times, store mp3 id3 tags, api gateway,
trigger transcription of audio,

Useful links to podcast xml guidelines
[google podcasat rss guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
[apple podcast connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)


# Infrastructure provisioned on AWS
 - 1 iam role
 - 3 iam role policy attachments
 - 1 iam role policy document
 - 1 sns topic
 - 1 lambda function
 - 2 s3 buckets (content bucket & rss feed bucket)
 - 2 cloudfront distributions
 - 1 hosted zone
 