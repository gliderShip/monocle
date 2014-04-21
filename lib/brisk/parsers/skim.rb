require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module Skim
      extend self

      BAD_TAG = 'script, style, link, option, input, form'
      BAD_CLASS = 'div[class*="comment"], div[class*="Comment"], div[class*="meta"], div[class*="foot"], div[class*="note"], div[class*="noprint"], div[class*="sidebar"], div[class*="widget"], span[class*="postinfo"], p[class*="caption"], div[class*="bookmarks"]'
      BAD_ID = 'div[id*="comment"], div[id*="Comment"], div[id*="meta"], div[id*="sidebar"], div[id*="widget"], div[id*="foot"], div[id*="note"], div[id*="noprint"], *:not([id*="content"]) > div[id*="right"], div[id*="bookmarks"]'
      SPACES = 'br'

      @logger = Logger.new('log/skim.log')

      def parse(base)

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
