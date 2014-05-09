require 'open-uri'
require 'nokogiri'

module Brisk
  module Parsers
    module OpenGraph
      extend self
      extend Encoding

      PROPERTIES = [
          'og:site_name',
          'og:type',
          'og:locale',
          'fb:app_id',
          'og:url',
          'og:title',
          'og:description',
          'description',
          'og:image',
          'article:published_time',
          'article:modified_time',
          'article:author',
          'article:section',
          'article:tag'
      ]

      IMG = ['.jpg', '.jpeg', '.png']

      REMOVE_IMG = ['logo', 'icon', 'blank', 'reklama', 'banner', 'placeholder']

      @logger = Logger.new('log/open_graph.log')

      def parse(base, isObject)

        @logger.info("OPEN START=======================================")

        if !isObject
          base = open(base)
          base = base.read
          base = encode(base)
          base = Nokogiri::HTML(base, nil, nil)

        end

        metaElems = base.css('meta')
        @logger.info("META START=======================================")
        @logger.info(metaElems.inspect)
        @logger.info("META END=======================================")
        openGraph = {}
        PROPERTIES.each { |property|
          openGraph[property] = parse_property(property, metaElems)
          openGraph
        }

        if openGraph['description'] && !openGraph['og:description']
          openGraph['og:description'] = openGraph['description']
        end
        if openGraph['og:image']
          openGraph['og:image'] = openGraph['og:image'].split('?')[0]
        end

        if !(openGraph['og:image'] && IMG.any? { |img| openGraph['og:image'].include? img })
          openGraph['og:image'] = nil
        end

        if (openGraph['og:image'] && REMOVE_IMG.any? { |img| openGraph['og:image'].include? img })
          openGraph['og:image'] = nil
        end

        if openGraph['og:type'].to_s.include?("video")
          openGraph['v:src'] = find_video_src(base);
        end

        @logger.info openGraph.inspect
        @logger.info("OPEN END=======================================")
        return openGraph
      end

      protected

      def parse_property(property, metaElems)
        if property.start_with?('og:')
        description = metaElems.at_css("meta[property=\"#{property}\"]")
        else
          description = metaElems.at_css("meta[name=\"#{property}\"]")
        end
        content = description && description['content']
        content && content.strip
      end

      def find_video_src(base)
        video_src_css = ['link[rel*="video_src"]', 'link[rel*="video"]', 'link[src*=".mp4"]']
        @logger.info("FIND VIDEO SRC START=======================================")
        video_src_css.each { |css|
          nodes = base.css(css)
          @logger.info("NODES START=======================================")
          @logger.info("CSS ===== " +css)
          @logger.info("NODES ====== " + nodes.inspect)
          @logger.info("NODES end=======================================")
          nodes.each { |node|
            if node['href']
              return node['href']
            elsif node['src']
              return node['src']
            elsif node['content']
              return node['content']
            else
              @logger.info("SRC NODE DIFF ========== -> " + node.inspect)
            end
          }
        }

        @logger.info("FIND VIDEO SRC END=======================================")
        return ''
      end

    end
  end
end
