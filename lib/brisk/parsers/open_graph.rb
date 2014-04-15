require 'open-uri'
require 'nokogiri'

module Brisk
  module Parsers
    module OpenGraph extend self
    extend Encoding

      PROPERTIES = [
        'og:site_name',
        'og:type',
        'og:locale', 
        'fb:app_id', 
        'og:url', 
        'og:title', 
        'og:description', 
        'description',
        'og:image', 
        'article:published_time', 
        'article:modified_time', 
        'article:author', 
        'article:section', 
        'article:tag'
      ]

      IMG = [ 'jpg', 'jpeg']

      def parse(base, isObject)

        if !isObject
          base      = open(base)
          base      = base.read
          base = encode(base)
          base = Nokogiri::HTML(base, nil, nil)

        end

        metaElems = base.css('meta')
        openGraph = {}
        PROPERTIES.each {| property|
          openGraph[property] = parse_property(property, metaElems)
          openGraph
        }

        if openGraph['og:image']
          openGraph['og:image'] = openGraph['og:image'].split('?')[0]
        end

        if !(openGraph['og:image'] && IMG.any? { |img| openGraph['og:image'].include? img })
          openGraph['og:image'] = nil
        end

        if( openGraph['og:image'] && openGraph['og:image'].include?('blank'))
          openGraph['og:image'] = nil
        end

        if( openGraph['og:image'] && openGraph['og:image'].include?('banner'))
          openGraph['og:image'] = nil
        end




        openGraph['og:description'] = nil
        return openGraph
      end
      
      protected

      def parse_property(property, metaElems)
        description = metaElems.at_css("meta[property=\"#{property}\"]")
        content     = description && description['content']
        content && content.strip
      end
    end
  end
end
