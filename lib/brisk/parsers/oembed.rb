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
                   'iframe[src*="youtube"]',
                   'iframe[src]',
                   'object[type="application/x-shockwave-flash"]',
                   'textarea[id="iframe-code"]'
                   ]

      VATRN = ['content', 'src', 'data', 'data-href']

      @logger = Logger.new('log/oembed.log')

      def parse(document)

        document.css(REMOVE_ID).remove
        document.css(REMOVE_CLASS).remove

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

                    v_src = video[attr];
                    if v_src.start_with?('//')
                      v_src = 'http:' + v_src;
                    end

                    uri = URI(v_src)

                    if uri.to_s.include?("video.top-channel.tv")
                      document = Nokogiri::HTML(open(uri))
                      return parse(document)
                    end

                    query = uri.query
                    if query
                    query_parts = CGI::parse(query)
                    query_parts = query_parts.each { |k, v|
                      query_parts[k] = v.first
                      query_parts[k] = 430 if k == "width" || k == "w"
                      query_parts[k] = 217 if k == "height" || k == "h"
                    }

                    query = URI.escape(query_parts.collect{|k,v| "#{k}=#{v}"}.join('&'))
                    uri.query = query

                    properties['src'] = uri.to_s
                    else
                      properties['src'] = uri.to_s
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
