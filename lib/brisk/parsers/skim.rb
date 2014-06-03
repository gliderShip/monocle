require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module Skim
      extend self

      BAD_TAG = 'time, footer, aside, noscript, script, style, option, input, aside, [role*="banner"], [role*="navigation"]'
      BAD_CLASS = 'div[class*="related-posts"], div[class="global-content-right"], [class="side-mod"], [class*="postim-data"], [class*="info-box"], [class*="-author"], [class*="author_info"], [class~="hide"], [class*="expand"], [class*="collapse"], [class*="didascalia"], [class*="date"], [class*="dropdown"], [class*="footer"], [class*="credits"], [class*="prev_"], [class~="skip"], div[class*="comment"], div[class*="Comment"], div[class*="meta"], div[class*="foot"], div[class*="note"], div[class*="noprint"], div[class~="sidebar"], div[class*="widget"], span[class*="postinfo"], [class*="articleinfo"], p[class*="caption"], div[class*="bookmarks"], div[class*="navigation"], div[class*="Navigation"], div[class="banner"], div[class*="breadcrumb"], [class*="sondag"], [class~="menu"]'
      BAD_ID = 'td[id*="news_page_text"] div[style*="float"], div[id*="footer"], div[id*="comment"], div[id*="Comment"], div[id*="meta"], div[id~="sidebar"], div[id*="widget"], div[id*="foot"], div[id*="note"], div[id*="noprint"], div[id*="bookmarks"], div[id="banner"]'
      SPACES = 'br'

      @logger = Logger.new('log/skim.log')

      def parse(base)
        @logger.info base.inspect
        base.css(BAD_TAG).remove
        base.css(BAD_CLASS).remove
        base.css(BAD_ID).remove
        base.search(SPACES).each do |spc|
          spc.replace(" ")
        end

        @logger.info("SKIM START=======================================")
        @logger.info base.inspect
        @logger.info("SKIM END=======================================")

        return base
      end
    end
  end
end
