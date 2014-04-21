require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module OEmbed
      extend self

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

      VIDEO_HOSTS = ['youtube', 'youtu', 'vimeo']

      VIDEO_CSS = ['meta[property="og:video"]', 'iframe[src]']

      VATRN = ['content', 'src']


      def parse(document)
        properties = {}
        VIDEO_CSS.each { |css|
          videos = document.css(css)
          videos.each { |video|
            VATRN.each { |attr|
              if video[attr]
                VIDEO_HOSTS.each { |host|
                  if video[attr].include?(host)
                    properties['src'] = video[attr]
                    videos.remove
                    return properties
                  end
                }
              end
            }
            video.remove
          }
        }

        return {}
        #Nestful.get(link['href']).decoded

      end


    end
  end
end
