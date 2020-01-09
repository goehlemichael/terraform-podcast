from xml.etree.ElementTree import Element, SubElement, tostring
from xml.etree import ElementTree
import boto3, os, time
from xml.dom import minidom

import urllib.parse

# import environment variables
cloudfront_content = os.environ['cloudfront_content']        # content cloudfront
podcast_name = os.environ['podcast_name']                    # podcast name
podcast_subtitle = os.environ['podcast_subtitle']            # podcast subtitle
podcast_author = os.environ['podcast_author']                # podcast author
podcast_desc = os.environ['podcast_desc']                    # podcast description
podcast_url = os.environ['podcast_url']                      # feed url
podcast_img_url = os.environ['podcast_img_url']              # link to podcast image url
podcast_type = os.environ['podcast_type']                    # type of podcast
podcast_xml_file_name = os.environ['podcast_xml_file_name']  # ex. podcast.xml
s3_bucket_trigger = os.environ['s3_bucket_trigger']          # trigger bucket name here
s3_bucket_rss = os.environ['s3_bucket_rss']                  # xml host bucket name here
email = os.environ['email']                                  # email here
copyright_text = os.environ['copyright_text']                # copyright text here
language = os.environ['language']                            # ex. en-us
website = os.environ['website']                              # www.example.com
category_one = os.environ['category_one']                    # category
sub_category_one = os.environ['sub_category_one']            # subcategory
category_two = os.environ['category_two']                    # category two
sub_category_two = os.environ['sub_category_two']            # subcategory two
explicit = os.environ['explicit']                            # yes, no

# reformat the xml


def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ElementTree.tostring(elem)
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="\t", newl="\n", encoding='UTF-8')

# create the XML document root


def make_root():
    """Generate xml file
    """
    rss = Element('rss', version='2.0')
    # headers
    rss.set('xmlns:atom', 'http://www.w3.org/2005/Atom')
    rss.set('xmlns:itunes', 'http://www.itunes.com/dtds/podcast-1.0.dtd')
    rss.set('xmlns:content', 'http://purl.org/rss/1.0/modules/content/')
    rss.set('xmlns:googleplay', 'http://www.google.com/schemas/play-podcasts/1.0')
    # channel
    channel = SubElement(rss, 'channel')
    SubElement(channel, 'generator').text = "https://github.com/goehlemichael/lambda-podcast"
    SubElement(channel, 'title').text = podcast_name
    SubElement(channel, 'itunes:subtitle').text = podcast_subtitle
    SubElement(channel, 'atom:link', href=podcast_url, rel='self', type='application/rss+xml')
    SubElement(channel, 'link',).text = website
    SubElement(channel, 'itunes:author').text = podcast_author
    SubElement(channel, 'itunes:explicit').text = explicit
    SubElement(channel, 'description').text = podcast_desc
    SubElement(channel, 'itunes:type').text = podcast_type
    # channel - owner
    owner = SubElement(channel, 'itunes:owner')
    SubElement(owner, 'itunes:name').text = podcast_name
    SubElement(owner, 'itunes:email').text = email
    SubElement(channel, 'managingEditor').text = email
    SubElement(channel, 'webMaster').text = email
    # END owner
    SubElement(channel, 'itunes:summary').text = podcast_desc
    SubElement(channel, 'itunes:image', href=podcast_img_url)
    # Category
    category = SubElement(channel, 'itunes:category', text=category_one)
    SubElement(category, 'itunes:category', text=sub_category_one)
    # END category 1
    # category two
    category_two_rss = SubElement(channel, 'itunes:category', text=category_two)
    SubElement(category_two_rss, 'itunes:category', text=sub_category_two)
    # end category two
    SubElement(channel, 'language').text = language
    SubElement(channel, 'copyright').text = copyright_text
    SubElement(channel, 'lastBuildDate').text = time.strftime("%a, %d %b %Y %H:%M:%S %z")
    SubElement(channel, 'pubDate').text = time.strftime("%a, %d %b %Y %H:%M:%S %z")
    # channel - image
    image = SubElement(channel, 'image')
    SubElement(image, 'url').text = podcast_img_url
    SubElement(image, 'title').text = podcast_name
    SubElement(image, 'link').text = podcast_url
    # END image

    s3_bucket_object = boto3.client('s3')
    content_list = s3_bucket_object.list_objects_v2(Bucket=s3_bucket_trigger)

    # for each object in the bucket create relevant xml tags
    for each_s3_object in content_list['Contents']:
        if 'mp3' in each_s3_object['Key'] and '/' in each_s3_object['Key']:

            description, title = each_s3_object['Key'].split('/')  # description = foldername, title = filename
            # item
            item = SubElement(channel, 'item')
            SubElement(item, 'description').text = str(description)
            SubElement(item, 'itunes:explicit').text = explicit
            SubElement(item, 'title').text = title.split('.')[0]
            SubElement(item, 'pubDate').text = each_s3_object['LastModified'].strftime("%a, %d %b %Y %H:%M:%S %z")
            SubElement(item, 'link').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])
            mp3_resource = each_s3_object['Key']
            mp3_url = cloudfront_content + urllib.parse.quote(mp3_resource)
            SubElement(item, 'enclosure', url=mp3_url, length=str(each_s3_object['Size']), type='audio/mpeg')
            SubElement(item, 'guid').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])

    # upload the podcast.xml file to S3
    create_podcast_file_content = prettify(rss)
    s3_bucket_object.put_object(Bucket=s3_bucket_rss, Body=create_podcast_file_content, Key=podcast_xml_file_name,
                                ContentType='application/xml')
# lambda handler


def handler(event, context):
    make_root()
