# terraform-podcast
terraform script for provisioning infrastructure to host your own podcast
wip
not ready to be used at all

# Infrastructure provisioned on AWS
 - 1 iam role
 - 3 iam role policy attachments
 - 1 iam role policy document
 - 1 sns topic
 - 1 lambda function
 - 2 s3 buckets (content bucket & rss feed bucket)
 - 2 cloudfront distributions
 - 1 hosted zone
 

# Setup

1) Set environment variables for lambda function in podcast.tf
2) create folder in content bucket - name it anything
3) put mp3 in folder just created - name it anything
4) put image.jpeg in content bucket - name it image.jpeg
5) test the lambda function executes
6) validate that the podcast.xml file exists in the rss bucket


To definitely do:
1) ensure no public access to bucket (cloudfront to bucket only)
2) certs
3) lambda cloudwatch alarm is not able to publish to the sns topic
4) create cloudfront alarm for bytes downloaded in the content bucket
5) create a new sns topic for that cloudfront alarm
6) generate a subscriber when script is executed
7) create module for everything
8) more logging
9) infrastructure tests, check endpoints are up, test bucket triggers lambda function

Useful links to podcast xml guidelines
[google podcasat rss guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
[apple podcast connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)

How to use:
You will need a domain name ideally already purchased through route53
Two main buckets:
The content bucket which stores the mp3s
and the rss feed which is where the lambda function stores the xml file it generates

To add an episode to the podcast its simple:
1) create a folder in the content s3 bucket, its name will = the description of that podcasts episode
2) inside that folder upload the mp3 for the episode, its name will = the episodes title

The changes will trigger the lambda function, the xml file will update in the rss bucket, after the cache expires the 
cloudfront instance will request an up to date object 

troubleshooting:
- make sure there are no folders in folders
- folder names are your description and file names are titles



after the steps in the setup,