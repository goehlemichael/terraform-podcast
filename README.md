# terraform-podcast
Terraform script for provisioning infrastructure to host a podcast on AWS
This is the basics you need to get a podcast up and running. There is no UI or web application.
episode creation, and updating media is done through the aws console or aws cli commands.

![Topology](podcast.jpeg)

# Setup

1) You need a domain name registered through aws [Instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
2) When the domain is registered you will have a hosted zone
3) With Certificate Manager get a certificate for the domainyouchoose.com with a *.domainyouchoose.com as alternative
4) run 'terraform apply' from the root of this directory and set variables using prompts

   or
   
   update and rename .tfvars.example file to example.tfvars
    
   terraform apply -var-file="example.tfvars"

# Using Infrastructure
1) Record/Edit your podcast episode using your choice of a media editing tool
2) Generate an mp3 and upload that mp3 to your content bucket in the aws web console
 
alternate - using aws cli
    
  Download contents of s3 content bucket to the directory you are in

    aws s3 sync s3://bucketname .

  sync the contents of the directory you are in with the s3 content bucket

    aws s3 sync . s3://bucketname
    
content bucket organization:

each directory is a podcast episode. Text files store the episode metadata. environment variables in the lambda function
store the podcast metadata. I plan to change the design and store this text data in a dynamodb table

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
# So what happens?

Now you will have an endpoint which is your rss feed sub domain - podcast.example.com

this can be shared with the major pocast directories like spotify, apple, google, etc.
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

improvement ideas: trigger transcription of audio

Useful links to podcast xml guidelines
[google podcasat rss guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
[apple podcast connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)
