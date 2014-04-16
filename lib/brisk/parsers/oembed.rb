require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module OEmbed extend self

      # PROPERTIES = {
      #     'version' => nil,
      #     'type' => nil,
      #     'provider_name' => nil,
      #     'provider_url' => nil,
      #     'width' => nil,
      #     'height' => nil,
      #     'title' => nil,
      #     'author_name' => nil,
      #     'author_url' => nil,
      #     'html' => nil,
      #     'src' => nil,
      # }

      VIDEO_HOSTS = [
        'youtube',
        'youtu',
        'vimeo'
      ]


      def parse(document)
        properties = {}
        iframe = document.css('iframe[src]')
        
        iframe.each { |video|
          VIDEO_HOSTS.each { |host|
            if video['src'].include?(host)
              properties['src'] = video['src']
              return properties
            end
          }
        }

        return {}
        #Nestful.get(link['href']).decoded

      end


    end
  end
end
