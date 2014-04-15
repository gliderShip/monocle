require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module OEmbed extend self

      PROPERTIES = {
          'version' => nil,
          'type' => nil,
          'provider_name' => nil,
          'provider_url' => nil,
          'width' => nil,
          'height' => nil,
          'title' => nil,
          'author_name' => nil,
          'author_url' => nil,
          'html' => nil,
          'src' => nil,
      }

      VIDEO_HOSTS = [
        'youtube',
        'youtu',
        'vimeo'
      ]

      def parse(document = nil, url = nil)

        if url
          document = crawl_url(url)
        end

        iframe = document.css('iframe[src]')
        
        iframe.each { |video|
          VIDEO_HOSTS.each { |host|
            if video['src'].include?(host)
              PROPERTIES['src'] = video['src']
              return PROPERTIES
            end
          }
        }

        return PROPERTIES
        #Nestful.get(link['href']).decoded

      end


      def crawl_url(url)
        ourl             = open(url)
        document         = Nokogiri::HTML(ourl, nil, nil)
        return document
      end


    end
  end
end
