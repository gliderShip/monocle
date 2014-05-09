require 'nokogiri'

module Brisk
  module Parsers
    module HTMLTitle extend self
    extend Encoding

      @logger = Logger.new('log/html_title.log')

      def parse(html)
        base  = Nokogiri::HTML(html, nil, nil)
        title = base.css('title').first
        title = title && title.inner_text.strip
        encode(title)
        puts title
        title && title.gsub!(/(.*\.com\ -\ |\ \|\ .*Gazeta.*|zzzzzzzz)/, '')

        @logger.info(title.inspect)
        return title
      end

    end
  end
end
