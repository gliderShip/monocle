require 'open-uri'
require 'nokogiri'

module Brisk
  module Parsers
    module Preview
      extend self

      IMG_SRC = [
          'data-cfsrc',
          'data-lazy-src',
          'data-original',
          'data-src',
      ]

      IMG_RMV =["reklama", ".png", ".gif", "blank", "banner", "subscribe", "transparent", "placeholder", "webtrekk", "noscript", "tradedoubler", "sample"]
      REMOVE = '[class*="sidepanel"], [id*="sidepanel"]'

      $image_pos = 50

      @logger = Logger.new('log/preview.log')


      def parse(base)

        base.css(REMOVE).remove
        images = base.css('img')

        @logger.info("IMAGES START=======================================")
        @logger.info(images.inspect)
        @logger.info("IMAGES END=======================================")

        if !images.empty?

          images = normalize_src(images)
          @logger.info("NORMALIZE START=======================================")
          @logger.info(images.inspect)
          @logger.info("NORMALIZE END=======================================")

          images = remove_undesired(images).uniq

          @logger.info("UNDESIRED START=======================================")
          @logger.info(images.inspect)
          @logger.info("UNDESIRED END=======================================")

          images = images.inject({}) do |hash, image|
            hash[image] = score(image)
            hash
          end

          image, score = images.sort_by { |k, v| v }.last
          src = image && image['src']

          @logger.info(image.inspect)
          return src


        end


      end

      protected

      def score(image)
        @logger.info("SCORE START=======================================")

        score = 0
        src = image['src']

        score += 10 if image.key?('title')
        score += 10 if image.key?('style')
        score -= 20 if image.parent.name. == "a"

        if image.key?('alt')
          score += 10
          alt = image['alt']
          score += 10 if !alt.empty?
          score += Math.sqrt(alt.length)
        end

        if image.key?('id')
          score += 25
        end

        if image.key?('width') && image['width'].to_i > 0
          width = image['width'].to_i
          score += Math.sqrt(width)
          @logger.info("width #{width}")
          @logger.info("width-score #{Math.sqrt(width)}")
        end

        if image.key?('height') && image['height'].to_i > 0
          height = image['height'].to_i
          score += Math.sqrt(height)
        end


        score += $image_pos
        $image_pos -= 5

        score -= 10 if src.include?('facebook')
        score -= 10 if src.include?('twitter')
        score -= 10 if src.include?('rss')

        score -= 30 if src.include?('logo')
        score -= 40 if src.include?('icon')
        score -= 50 if src.include?('reklama')

        score += 10 if src.include?('http')
        score += 20 if src.include?('jpg') || src.include?('JPG')
        score += 20 if src.include?('jpeg') || src.include?('JPEG')

        @logger.info(src.inspect)
        @logger.info(score)
        @logger.info("SCORE END=======================================")

        score
      end

      def normalize_src(images)
        images.each { |image|
          image.each { |attr_name, attr_value|
            IMG_SRC.each { |src_name|
              if attr_name == src_name
                image['src']= attr_value
              end
            }
          }
        }

        return images
      end

      def remove_undesired(images)
        tmp = []
        unique = []
        images.each { |image|
          src = image['src']
          include = true
          if !unique.include?(src.to_s)
            unique.push(src.to_s)
            IMG_RMV.each { |undesired|

              if src.to_s.include?(undesired)
                include = false
              end
            }
          else
            include = false
          end

          tmp.push(image) if include
        }

        return tmp
      end

    end
  end
end
