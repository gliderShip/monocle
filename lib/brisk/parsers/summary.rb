require 'nokogiri'

module Brisk
  module Parsers
    module Summary
      extend self
      extend Encoding

      REMOVE_TAG = 'h1, h2, h3, h4, h5, pre, code, before, stats, ul, form, map'
      REMOVE_CLASS = '[class*="postim-titull"], [class*="caption"], [class="source"],[class="image"],[class*="header"], [class*="before"], [class*="stats"], [class*="date"], [class*="img"], [class="reader"], [class*="skip"], [class*="tools"], [class*="share"], [class*="history"], [style*="display:none"]'
      REMOVE_ID = '[id*="before"], [id*="stats"], [id*="tools"], [id*="share"]'

      @logger = Logger.new('log/summary.log')

      SUMMARY_CSS = {
          'shek' => 'div[class*="postim-text"]',
          'alt' => 'div[class*="article-body"]',
          'usmag1'          => 'div[id*="article-body"]',
          'corriere' => 'div[class*="article-content"]',
          'sport' => 'div[class*="desc-article"]',
          'panorama_v0' => 'div[class*="post"] > p',
          'panorama_v1' => 'div[class*="post"]',
          'panorama_v2' => 'div[id*="primary"]',
          'ballkan_v1' => 'td[width="100%"][class^="font1"]',
          'ballkan_v2' => 'td[width="100%"][class^="font2"]',
          'ballkan_v3' => 'td[width="100%"][class^="font3"]',
          'ballkan_v4' => 'td[class^="font1"]',
          'ballkan_v5' => 'td[class^="font2"]',
          'shqiptarja' => '[id$="text"]',
          'ballkan_v6' => 'div[class^="font"]',
          'top_channel_v1' => 'span[class^="arial1"]',
          'top_channel_v2' => 'span[class^="arial2"]',
          'top_channel_v3' => 'span[class^="treb1"]',
          'base' => 'p',
          'mess1' => 'div[class*="articolo"]',
          'mess2' => 'div[class*="testo"]',
          'corr1' => 'div[class*="text"]',
          'corr2' => 'div[id*="text"]',
          'mess3' => 'div[id*="articolo"]',
          'mess4' => 'div[id*="testo"]',
          'base2' => '[class*="article"]',
      }

      def parse(base, url)

        return '' unless base

        base.css(REMOVE_TAG).remove
        base.css(REMOVE_CLASS).remove
        base.css(REMOVE_ID).remove
        base.text.gsub!(/\t+/, ' ')
        base.text.gsub!(/\s+/, ' ')

        @logger.info(base)

        text = nil
        nodes = nil

        SUMMARY_CSS.each_value { |css_path|
          nodes = base.css(css_path)
          @logger.info("CSS START=======================================")
          @logger.info(css_path)
          @logger.info(nodes.inspect)
          @logger.info("CSS END=======================================")
          if !nodes.empty?
            break
          end
        }

        if nodes.inner_text.length < 100
          @logger.info("FAILED CSS TEXT START=======================================")
          nodes += base.search('text()')
          @logger.info(nodes)
          @logger.info("FAILED CSS TEXT END=======================================")
        end

        @logger.info("SUMMARY START=======================================")
        @logger.info(nodes)
        @logger.info("SUMMARY END=======================================")
        if !nodes.empty?

          text = nodes.map { |p|
            @logger.info(p.inspect)
            if p.inner_text.strip.length > 4
              if p.name == "strong" || p.name == "em" || p.name == "a"
                new_content = "«" + p.inner_text.strip + "»"
              else
                @logger.info(":::name:::" + p.name)
                p.inner_text.strip << "."
              end
            elsif p.inner_text.strip.length > 1
              p.inner_text.strip
            end
          }

          text.compact!
          @logger.info("SNIPPET START=======================================")
          @logger.info(text)
          @logger.info("SNIPPET END=======================================")
          text = text.select { |t| t.start_with?("«") || t.length > 20 }
          base.text.gsub!(/\s+/, ' ')
          text = text.join(' ')[0..900]
          return text
        end


        return text
      end

    end
  end
end
