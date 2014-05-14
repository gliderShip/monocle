require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module OEmbed
      extend self

      REMOVE_TAG = ''
      REMOVE_CLASS = '[class*="tools"], [class*="share"], [class*="history"], [style*="display:none"]'
      REMOVE_ID = '[id*="-slider"]'

      VIDEO_HOSTS = ['youtube', 'youtu', 'vimeo', 'video', 'embed']

      VIDEO_CSS = ['meta[property="og:video"]',
                   'iframe[src]',
                   'object[type="application/x-shockwave-flash"]',
                   'textarea[id="iframe-code"]'
                   ]

      VATRN = ['content', 'src', 'data', 'data-href']

      @logger = Logger.new('log/oembed.log')

      def parse(document)

        document.css(REMOVE_ID).remove

        @logger.info("INPUT START=======================================")
        @logger.info(document.inspect)
        @logger.info("INPUT END=======================================")

        properties = {}
        @logger.info("OEMBED START=======================================")
        VIDEO_CSS.each { |css|
          @logger.info("CSS  :" + css)
          videos = document.css(css)
          @logger.info("    VIDEOS  :" + videos.inspect)
          videos.each { |video|
            @logger.info("        VIDEO  :" + video.inspect)
            VATRN.each { |attr|
              if video[attr]
                VIDEO_HOSTS.each { |host|
                  if video[attr].include?(host)
                    properties['src'] = video[attr]
                    if properties['src'].include?('?')
                      properties['src'] += '&width=430&height=217'
                    else
                      properties['src'] += '?width=430&height=217'
                    end
                    videos.remove
                    ("PROPERTIES  :" + properties.inspect)
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
