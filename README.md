# terraform-podcast

Terraform module for provisioning infrastructure to host a podcast on AWS.

This is the basics you need to get a podcast up and running. There is no UI or web application.

Episode creation, and updating media is done through the aws console or aws cli commands.

## Topology

![Topology](https://raw.githubusercontent.com/goehlemichael/terraform-podcast/master/podcast.jpeg)

## Quick Start from root directory (Must have tls cert and domain setup)

```bash
make test
```

## Quick Setup

1) Register a domain through aws [Instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
2) After creation, you will have a hosted zone.
3) Using 'Certificate Manager' get a certificate for `<domainyouchoose>.com` with a `*.<domainyouchoose.com>` as alternative.
4) Prior to step 5, you can also create a variables file and name it _whateveryouwant.tfvars_
5) Inside the versions.tf update the profile value to the aws profile you wish to apply changes to
6) Run `terraform apply` from the root of this directory and set variables using prompts.

   or

   using the example .tfvars file,udpate _.tfvars.example_ file to _whateveryouwant.tfvars_ and fill in the variable values

   ```bash
   terraform plan -var-file="whateveryouwant.tfvars"
   terraform apply -var-file="whateveryouwant.tfvars"
   ```

## Using Infrastructure

1) Record/Edit podcast episode using your choice of a media editing tool
2) Export audio in a supported audio (mp3 or m4a) format and upload to your 'content_bucket_name' in the aws web console

- alternative - using aws-cli

  sync contents of directory you are in with s3 content bucket

  ```bash
  aws s3 sync . s3://<MEDIA BUCKET NAME> --exclude "*.DS_Store*"
  ```

3) Invalidate the cloudfront cache ID = media distribution id

   ```bash
   aws cloudfront create-invalidation --distribution-id <ID> --paths "/podcast.xml"
   ```

### Content bucket organization

Podcast episodes are configured using the structure below in the media bucket. Environment variables in the lambda function
are used to configure the podcast.

```bash
. examples
+-- single_podcast_aws
    +-- main.tf
    +-- media
        +-- image.jpeg
        +-- episode1
            +-- episode1.mp3
            +-- image.jpeg
            +-- title.txt
            +-- description.txt
            +-- pubdate.txt
            +-- duration.txt
            +-- explicit.txt
            +-- episodetype.txt
    +-- rss
        +-- podcast.xml
    +-- vars
        +-- example.tfvars
```

## What happens

### A rss feed endpoint compatible with major podcast directories is created

Terraform outputs:

- podcast_url = domain rss feed hosted at
- podcast_feed_cdn_url = cloudfront url of rss feed
- content_bucket_url = s3
- log_bucket_url
- content_cdn_url
- lambda_name
- region

your rss feed subdomain - `podcast.example.com`

This can be shared with the major podcast directories like Spotify, Apple, Google, etc.

## How to tear down

  ```bash
  make destroy
  ```

Useful links to podcast xml guidelines:

- [Google Podcast RSS Guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
- [Apple Podcast Connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)
