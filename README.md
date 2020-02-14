# terraform-podcast
terraform script for provisioning infrastructure to host your own podcast

![Topology](podcast.jpeg)

# Setup

1) You need a domain name registered
2) When the domain is registered you will have a hosted zone

    export TF_VAR_domain_name=example.com
    
    export TF_VAR_content_domain_name=podcastcontent.example.com
    
    export TF_VAR_rss_domain_name=podcast.example.com
    
    export TF_VAR_rss_bucket_name=podcast-rss-bucket-name-example
    
    export TF_VAR_content_bucket_name=podcast-content-bucket-name-example
    
    terraform apply
    
    or
    
    terraform apply \
    -var 'domain_name=example.com' \
    -var 'content_domain_name=podcastcontent.example.com' \
    -var 'rss_domain_name=podcast.example.com' \
    -var 'rss_bucket_name=podcast-rss-bucket-name-example' \
    -var 'content_bucket_name=podcast-content-bucket-name-example'

# Using Infrastructure
1) Record/Edit your podcast episode
2) From inside aws -> s3 -> your content bucket
 
alternate - using aws cli
From inside a folder with a single folder for each podcast episode
    
  Download contents of s3 content bucket to the directory you are in

    aws s3 sync s3://bucketname .

  sync the contents of the directory you are in with the s3 content bucket

    aws s3 sync . s3://bucketname
    
content bucket current organization:

each directory is a podcast episode. Files store the episode metadata. environment variables in the lambda function store the podcast metadata.
I plan to move this to a dynamodb table

```
.
+-- episode1
    +-- episode1.mp3
    +-- image.jpeg
    +-- title.txt
    +-- description.txt
    +-- pubdate.txt
    +-- explicit.txt
+-- episode2
    +-- episode2.mp3
    +-- image.jpeg
    +-- title.txt
    +-- description.txt
    +-- pubdate.txt
    +-- explicit.txt
+-- image.jpeg
```

# Run Tests
    cd tests; go test -timeout 45m | tee test_output.log

To definitely do:
1) ensure no public access to bucket (cloudfront to bucket only)
2) lambda cloudwatch alarm is not able to publish to the sns topic
3) create cloudfront alarm for bytes downloaded in the content bucket
4) create a new sns topic for that cloudfront alarm
5) generate a subscriber when script is executed
6) modules
7) more logging
8) tests: rss feed test, xml validation, content/rss buckets can't be reached publicly
9) cloudwatch dashboard with metrics on cloudfront downloads

improvement ideas: dynamo db store creation/upload times, trigger transcription of audio

Useful links to podcast xml guidelines
[google podcasat rss guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
[apple podcast connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)
