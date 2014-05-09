require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module Schemaorg
      extend self

      REMOVE_TAG = ''
      REMOVE_CLASS = '[class*="expand"], [class*="collapse"]'
      REMOVE_ID = ''

      ARTICLE = [
          'articleBody',
          'articleSection',
      ]

      VIDEO_OBJECT = [
          'caption',
          'thumbnail',
      ]

      IMAGE_OBJECT = [
          'caption',
          'representativeOfPage',
          'thumbnail',
      ]

      MEDIA_OBJECT = [
          'associatedArticle',
          'contentSize',
          'contentUrl',
          'embedUrl',
          'encodesCreativeWork',
          'encodingFormat',
          'height',
          'productionCompany',
          'publication',
          'uploadDate',
          'width',
      ]

      WEB_PAGE = [
          'contentUrl',
          'breadcrumb',
          'isPartOf',
          'mainContentOfPage',
          'primaryImageOfPage',
          'videoUrl',
      ]

      IMAGE_GALLERY = COLLECTION_PAGE = WEB_PAGE

      CREATIVE_WORK = [
          'about',
          'associatedMedia',
          'author',
          'headline',
          'contentLocation',
          'review',
          'publisher',
          'text',
          'thumbnailUrl',
          'thumbnailUrl',
          'video',
      ]

      THING = [
          'additionalType',
          'description',
          'image',
          'name',
          'url',
      ]


      TYPES = {'http://schema.org/VideoObject' => VIDEO_OBJECT,
               'http://schema.org/ImageObject' => IMAGE_OBJECT,
               'http://schema.org/ImageGallery' => IMAGE_GALLERY,
               'http://schema.org/MediaObject' => MEDIA_OBJECT,
               'http://schema.org/Article' => ARTICLE,
               'http://schema.org/WebPage' => WEB_PAGE
      }


      @logger = Logger.new('log/schemaorg.log')


      def parse(document)

        document.css(REMOVE_CLASS).remove

        properties = {}
        nodes = document.css('[itemscope]')
        @logger.info("#{nodes.length} ITEMS FOUND =======================================")

        if nodes
          nodes.each { |item|
            itemtype = item['itemtype']
            TYPES.each { |type, value|
              if itemtype == type
                typeProp = parse_type(type, item)
                properties.merge!(typeProp)
              end
            }

            @logger.info("TYPE :: #{itemtype}")
            @logger.info("properties START=======================================")
            @logger.info(properties.inspect)
            @logger.info("properties END=======================================")
          }
        end
        return properties

      end

      def parse_type(type, item)
        case type
          when 'http://schema.org/VideoObject'
            return parse_video_object(item)
          when 'http://schema.org/ImageObject'
            return parse_image_object(item)
          when 'http://schema.org/ImageGallery'
            return parse_image_gallery(item)
          when 'http://schema.org/MediaObject'
            return parse_media_object(item)
          when 'http://schema.org/Article'
            return parse_article(item)
          when 'http://schema.org/WebPage'
            return parse_web_page(item)
          else
            @logger.info("#{type} NOT FOUND =======================================")
            return {}
        end
      end

      def parse_video_object(document)
        properties = parse_object(VIDEO_OBJECT, document).merge(parse_media_object(document))
        return properties
      end

      def parse_image_object(document)
        properties = parse_object(IMAGE_OBJECT, document).merge(parse_media_object(document))
        return properties
      end

      def parse_media_object(document)
        properties = parse_object(MEDIA_OBJECT, document).merge(parse_creative_work(document))
        return properties
      end

      def parse_article(document)
        properties = parse_object(ARTICLE, document).merge(parse_creative_work(document))
        return properties
      end

      def parse_image_gallery(document)
        return parse_collection_page(document)
      end

      def parse_collection_page(document)
        return parse_web_page(document)
      end

      def parse_web_page(document)
        properties = parse_object(WEB_PAGE, document).merge(parse_creative_work(document))
        if properties['contentUrl'].to_s.include?('.mp4')
          properties['videoUrl'] = properties['contentUrl']
        else
          properties['videoUrl'] = '';
        end
        return properties
      end

      def parse_creative_work(document)
        properties = parse_object(CREATIVE_WORK, document).merge(parse_thing(document))
        return properties
      end

      def parse_thing(document)
        return parse_object(THING, document)
      end

      def parse_object(object, document)

        properties = {}
        object.each { |prop|
          node = document.at_css("[itemprop~=#{prop}]")
          if node
            node = clean_node(node, prop);
            if node['content']
              properties[prop] = node['content']
            elsif node['src']
              properties[prop] = node['src']
            else
              properties[prop] = node.inner_text.strip
            end
          end

        }

        @logger.info("object prop  END=======================================")
        @logger.info(properties.inspect)
        @logger.info("object prop START=======================================")
        return properties
      end

      def clean_node(node, prop)
        @logger.info("CLEAN START=======================================")
        if prop == 'articleBody'
          node.css('h1, h2, h3, ul, [class*="reader"]').remove
        end
        @logger.info(prop + ' :::::: ' + node.inspect)
        @logger.info("CLEAN END=======================================")
        return node
      end

    end
  end
end