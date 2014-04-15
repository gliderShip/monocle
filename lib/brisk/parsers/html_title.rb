require 'nokogiri'

module Brisk
  module Parsers
    module HTMLTitle extend self
    extend Encoding

      def parse(html)
        base  = Nokogiri::HTML(html, nil, nil)
        title = base.css('title').first
        encode(title && title.inner_text.strip)
      end

    end
  end
end
