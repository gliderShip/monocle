require 'nestful'
require 'nokogiri'

module Brisk
  module Parsers
    module Video extend self
      def parse(base)
        link = base.css('link[type="application/json+oembed"]').first
        return unless link
        return '//www.youtube.com/embed/Vz5oYUeXLKo'
        Nestful.get(link['href']).decoded
      end
    end
  end
end
