require 'nokogiri'

module Brisk
  module Parsers
    module Preview extend self

    IMG_CSS = {
        'good_jpg_css'  => 'body img[src^="http"][src*="jpg"]',
        'good_jpeg_css' => 'body img[src^="http"][src*="jpeg"]',
        'bad_jpg_css'   => 'body img[src*="jpg"]',
        'bad_jpeg_css'  => 'body img[src*="jpeg"]',
        'bad'           => 'img'
    }

    IMG_SRC = [
        'src',
        'data-cfsrc',
        'data-lazy-src',
        'data-original',
        'data-src',
    ]

    def parse(base)
      IMG_CSS.each_value { |css_path|
        images = base.css(css_path)
        puts images.inspect
        if !images.empty?
          images.each { |image|
            IMG_SRC.each { |src_name|
              src = image[src_name]
              if src && !src.include?('blank') && !src.include?('banner')
                return src
              end
            }
          }
        end
      }
    end

    end
  end
end
