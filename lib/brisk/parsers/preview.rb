require 'open-uri'
require 'nokogiri'

module Brisk
  module Parsers
    module Preview
      extend self

      IMG_CSS = {
          'good_jpg_css' => "body img[src^='http'][src*='.jpg']",
          'good_jpgU_css' => "body img[src^='http'][src*='.JPG']",
          'good_jpeg_css' => "body img[src^='http'][src*='.jpeg']",
          'good_jpegU_css' => "body img[src^='http'][src*='.JPEG']",
          'bad_jpg_css' => "body img[src*='.jpg']",
          'bad_jpgU_css' => "body img[src*='.JPG']",
          'bad_jpeg_css' => "body img[src*='.jpeg']",
          'bad_jpegU_css' => "body img[src*='.JPEG']",
          'bad' => 'img'
      }

      IMG_SRC = [
          'src',
          'data-cfsrc',
          'data-lazy-src',
          'data-original',
          'data-src',
      ]

      $image_pos = 10

      @logger = Logger.new('log/preview.log')

      def parse(base)

        IMG_CSS.each_value { |css_path|
          @logger.info("IMAGES START=======================================")
          images = base.css(css_path)
          @logger.info(images.inspect)
          @logger.info("IMAGES END=======================================")

          if !images.empty?
            srcs = []

            images.each { |image|
              IMG_SRC.each { |src_name|
                src = image[src_name]
                if src && !src.include?('blank') && !src.include?('banner') && !src.include?('subscribe')
                  srcs.push(src)
                end
              }
            }

            srcs = srcs.inject({}) do |hash, src|
              hash[src] = score(src)
              hash
            end

            src, score = srcs.sort_by { |k, v| v }.last
            return src


          end
        }


      end

      def score(src)
        @logger.info("SCORE START=======================================")
        score = 0
        score += $image_pos
        $image_pos -= 1
        score -= 10 if src.include?('logo')
        score -= 20 if src.include?('icon')
        score -= 30 if src.include?('reklama')
        @logger.info(src.inspect)
        @logger.info(score)
        @logger.info("SCORE END=======================================")

        score
      end

    end
  end
end
