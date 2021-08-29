# terraform-podcast

Terraform script for provisioning infrastructure to host a podcast on AWS.

This is the basics you need to get a podcast up and running. There is no UI or web application.

Episode creation, and updating media is done through the aws console or aws cli commands.

## Topology

![Topology](https://raw.githubusercontent.com/goehlemichael/terraform-podcast/master/podcast.jpeg)

## Quick Start from root directory (Must have tls cert and domcain setup)

```bash
$ cd tests
```
```bash
$ go test -v -timeout 30m
```

## Setup

1) You need a domain name registered through aws [Instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
2) When the domain is registered you will have a hosted zone
3) With Certificate Manager get a certificate for the `domainyouchoose.com` with a `*.domainyouchoose.com` as alternative
4) Run `terraform apply` from the root of this directory and set variables using prompts

   or

   update and rename _.tfvars.example_ file to _example.tfvars_

   ```bash
   terraform apply -var-file="example.tfvars"
   ```

## Using Infrastructure

1) Record/Edit your podcast episode using your choice of a media editing tool
2) Export an mp3 and upload that mp3 to your content bucket in the aws web console

   alternate - using aws cli

   Download contents of s3 content bucket to the directory you are in

   ```bash
   aws s3 sync s3://<MEDIA BUCKET> .
   ```

   sync the contents of the directory you are in with the s3 content bucket

   ```bash
   aws s3 sync . s3://<MEDIA BUCKET NAME>
   ```

3) Invalidate the cloudfront cache <ID> = media distribution id

   ```bash
   aws cloudfront create-invalidation --distribution-id <ID> --paths "/podcast.xml"
   ```

### Content bucket organization

Podcast episodes are configured using the structure below in the media bucket. Environment variables in the lambda function
are used to configure the podcast.

```bash
.
+-- episode1
    +-- episode1.mp3
    +-- image.jpeg
    +-- title.txt
    +-- description.txt
    +-- pubdate.txt
    +-- duration.txt
    +-- explicit.txt
+-- episode2
    +-- episode2.mp3
    +-- image.jpeg
    +-- title.txt
    +-- description.txt
    +-- pubdate.txt
    +-- duration.txt
    +-- explicit.txt
+-- image.jpeg
```

## What happens

Now you will have an endpoint which is your rss feed sub domain - `podcast.example.com`

This can be shared with the major pocast directories like Spotify, Apple, Google, etc.

Useful links to podcast xml guidelines:

- [Google Podcasat RSS Guidelines](https://developers.google.com/search/docs/guides/podcast-guidelines)
- [Apple Podcast Connect](https://help.apple.com/itc/podcasts_connect/#/itcc0e1eaa94)
