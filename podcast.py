from xml.etree.ElementTree import Element, SubElement
from xml.etree import ElementTree
import boto3, os, time
from xml.dom import minidom
import urllib

# import environment variables #########################################################################################
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
    # headers ##########################################################################################################
    rss.set('xmlns:atom', 'http://www.w3.org/2005/Atom')
    rss.set('xmlns:itunes', 'http://www.itunes.com/dtds/podcast-1.0.dtd')
    rss.set('xmlns:content', 'http://purl.org/rss/1.0/modules/content/')
    rss.set('xmlns:googleplay', 'http://www.google.com/schemas/play-podcasts/1.0')
    # channel - podcast defined here ###################################################################################
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
    # channel - owner ##################################################################################################
    owner = SubElement(channel, 'itunes:owner')
    SubElement(owner, 'itunes:name').text = podcast_name
    SubElement(owner, 'itunes:email').text = email
    SubElement(channel, 'managingEditor').text = email
    SubElement(channel, 'webMaster').text = email
    # END owner ########################################################################################################
    SubElement(channel, 'itunes:summary').text = podcast_desc
    SubElement(channel, 'itunes:image', href=podcast_img_url)
    # Category #########################################################################################################
    category = SubElement(channel, 'itunes:category', text=category_one)
    SubElement(category, 'itunes:category', text=sub_category_one)
    # END category 1####################################################################################################
    # category two #####################################################################################################
    category_two_rss = SubElement(channel, 'itunes:category', text=category_two)
    SubElement(category_two_rss, 'itunes:category', text=sub_category_two)
    # end category two #################################################################################################
    SubElement(channel, 'language').text = language
    SubElement(channel, 'copyright').text = copyright_text
    SubElement(channel, 'lastBuildDate').text = time.strftime("%a, %d %b %Y %H:%M:%S %z")
    SubElement(channel, 'pubDate').text = time.strftime("%a, %d %b %Y %H:%M:%S %z")
    # channel - image ##################################################################################################
    image = SubElement(channel, 'image')
    SubElement(image, 'url').text = podcast_img_url
    SubElement(image, 'title').text = podcast_name
    SubElement(image, 'link').text = podcast_url
    # END image ########################################################################################################

    s3_bucket_object = boto3.client('s3')
    content_list = s3_bucket_object.list_objects_v2(Bucket=s3_bucket_trigger, Delimiter='episode')

    # for each object in the bucket create relevant xml tags ###########################################################
    for each_s3_object in content_list['Contents']:
        if 'mp3' in each_s3_object['Key']:

            episode, media = each_s3_object['Key'].split('/')  # episode = foldername, title = filename
            # get publish dates for each episode #######################################################################
            string_date_url = cloudfront_content + urllib.parse.quote(episode + '/pubdate.txt')
            date = urllib.request.urlopen(string_date_url)
            publish_date = date.read().decode('utf-8')
            # get image url ############################################################################################
            episode_image = cloudfront_content + urllib.parse.quote(episode + '/image.jpeg')
            # get episode duration
            duration_url = cloudfront_content + urllib.parse.quote(episode + '/duration.txt')
            duration_bytes = urllib.request.urlopen(duration_url)
            duration = duration_bytes.read().decode('utf-8')
            # get episode description ##################################################################################
            description_url = cloudfront_content + urllib.parse.quote(episode + '/description.txt')
            description_bytes = urllib.request.urlopen(description_url)
            description_text = description_bytes.read().decode('utf-8')
            # get if explicit or not
            # string_explicit_url = cloudfront_content + urllib.parse.quote(episode + '/explicit.txt')
            # explicit_bytes = urllib.request.urlopen(string_explicit_url)
            # explicit = explicit_bytes.read().decode('utf-8')
            # get episode title
            title_url = cloudfront_content + urllib.parse.quote(episode + '/title.txt')
            title_bytes = urllib.request.urlopen(title_url)
            title_text = title_bytes.read().decode('utf-8')
            # get episode type #########################################################################################
            episode_type = cloudfront_content + urllib.parse.quote(episode + '/episodetype.txt')
            episode_type_bytes = urllib.request.urlopen(episode_type)
            episode_type_text = episode_type_bytes.read().decode('utf-8')
            # item - each episode defined here #########################################################################
            item = SubElement(channel, 'item')
            SubElement(item, 'description').text = description_text
            SubElement(item, 'itunes:explicit').text = explicit
            SubElement(item, 'itunes:image', href=episode_image)
            SubElement(item, 'title').text = title_text
            SubElement(item, 'pubDate').text = publish_date
            SubElement(item, 'itunes:duration').text = duration
            SubElement(item, 'itunes:episodeType').text = episode_type_text
            SubElement(item, 'link').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])
            mp3_resource = each_s3_object['Key']
            mp3_url = cloudfront_content + urllib.parse.quote(mp3_resource)
            SubElement(item, 'enclosure', url=mp3_url, length=str(each_s3_object['Size']), type='audio/mpeg')
            SubElement(item, 'guid').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])

    for each_s3_object in content_list['Contents']:
        if 'm4a' in each_s3_object['Key']:
            episode2, media2 = each_s3_object['Key'].split('/')  # episode2 = foldername, title = filename
            # get publish dates for each episode #######################################################################
            string_date_url2 = cloudfront_content + urllib.parse.quote(episode2 + '/pubdate.txt')
            date = urllib.request.urlopen(string_date_url2)
            publish_date2 = date.read().decode('utf-8')
            # get image url ############################################################################################
            episode_image2 = cloudfront_content + urllib.parse.quote(episode2 + '/image.jpeg')
            # get episode duration #####################################################################################
            duration_url2 = cloudfront_content + urllib.parse.quote(episode2 + '/duration.txt')
            duration_bytes2 = urllib.request.urlopen(duration_url2)
            duration = duration_bytes2.read().decode('utf-8')
            # get episode description ##################################################################################
            description_url2 = cloudfront_content + urllib.parse.quote(episode2 + '/description.txt')
            description_bytes2 = urllib.request.urlopen(description_url2)
            description_text2 = description_bytes2.read().decode('utf-8')
            # get if explicit or not
            # string_explicit_url = cloudfront_content + urllib.parse.quote(episode2 + '/explicit.txt')
            # explicit_bytes = urllib.request.urlopen(string_explicit_url)
            # explicit = explicit_bytes.read().decode('utf-8')
            # get episode title
            title_url2 = cloudfront_content + urllib.parse.quote(episode2 + '/title.txt')
            title_bytes2 = urllib.request.urlopen(title_url2)
            title_text2 = title_bytes2.read().decode('utf-8')
            # get episode type #########################################################################################
            episode_type2 = cloudfront_content + urllib.parse.quote(description2 + '/episodeType.txt')
            episode_type_bytes2 = urllib.request.urlopen(episode_type2)
            episode_type_text2 = episode_type_bytes2.read().decode('utf-8')
            # item - each episode defined here #########################################################################
            item = SubElement(channel, 'item')
            SubElement(item, 'description').text = description_text2
            # SubElement(item, 'itunes:explicit').text = explicit
            SubElement(item, 'itunes:image', href=episode_image2)
            SubElement(item, 'title').text = title_text2
            SubElement(item, 'pubDate').text = publish_date2
            SubElement(item, 'itunes:duration').text = duration
            SubElement(item, 'itunes:episodeType').text = episode_type_text2
            SubElement(item, 'link').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])
            m4a_resource = each_s3_object['Key']
            m4a_url = cloudfront_content + urllib.parse.quote(m4a_resource)
            SubElement(item, 'enclosure', url=m4a_url, length=str(each_s3_object['Size']), type='audio/m4a')
            SubElement(item, 'guid').text = cloudfront_content + urllib.parse.quote(each_s3_object['Key'])

    # upload the podcast.xml file to S3 ################################################################################
    create_podcast_file_content = prettify(rss)
    s3_bucket_object.put_object(Bucket=s3_bucket_rss, Body=create_podcast_file_content, Key=podcast_xml_file_name,
                                ContentType='application/xml')


def handler(event, context):
    make_root()
