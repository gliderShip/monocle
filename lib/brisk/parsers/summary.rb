require 'nokogiri'

module Brisk
  module Parsers
    module Summary extend self
      extend Encoding

    REMOVE_TAG = ['h1, h2, h3, h4, h5, pre, code, strong, before, stats']
    REMOVE_CLASS = '[class*="before"], [class*="stats"]'
    REMOVE_ID = '[id*="before"], [id*="stats"]'

      SUMMARY_CSS  = {
          'base'            => 'p',
          'panorama_v1'    => 'div[class*="post"]',
          'panorama_v2'    => 'div[id*="primary"]',
          'ballkan_v1'      => 'td[width="100%"][class^="font1"]',
          'ballkan_v2'      => 'td[width="100%"][class^="font2"]',
          'ballkan_v3'      => 'td[width="100%"][class^="font3"]',
          'ballkan_v4'      => 'td[class^="font1"]',
          'ballkan_v5'      => 'td[class^="font2"]',
          'ballkan_v6'      => 'div[class^="font"]',
          'top_channel_v1'  => 'span[class^="arial1"]',
          'top_channel_v2'  => 'span[class^="arial2"]',
          'top_channel_v3'  => 'span[class^="treb1"]',
      }

      def parse(base, url)
        base.css(REMOVE_TAG).remove
        base.css(REMOVE_CLASS).remove
        base.css(REMOVE_ID).remove

        SUMMARY_CSS.each_value { |css_path|
          text = base.css(css_path)



          if !text.empty?
            text = text.map {|p| p.inner_text.strip }
            text = text.select {|t| t.length > 20 }
            text = text.join(' ')[0..900]
            return text
          end
        }

      end

    end
  end
end
