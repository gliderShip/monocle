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
        title && title.gsub!(/(.*\.com\ -\ |\ \|\ .*Gazeta.*|zzzzzzzz)/, '')
        if title.to_s.length >= 40 && (title.include?(' - ') || title.include?(' | '))
          tr_title = title.split(" - ").sort_by(&:length).last
          tr_title =  tr_title.split(" | ").sort_by(&:length).last unless tr_title.to_s.length < 40
          title =  tr_title unless tr_title.to_s.length < 40
        end

        @logger.info(title.inspect)
        return title
      end

    end
  end
end
