# encoding: utf-8

require 'nokogiri'

module Brisk
  module Parsers
    module Readability extend self
      extend Encoding

      NEGATIVE = /(comment|meta|footer|footnote|info|before|stats)/
      POSITIVE = /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/

      ARTICLE_CSS  = {
          'panorama_v1'     => 'div[class*="post"]',
          'panorama_v2'     => 'div[id*="primary"]',
          'ballkan_v1'      => 'body table tr td[width="100%"][class^="font1"]',
          'ballkan_v2'      => 'body table tr td[width="100%"][class^="font2"]',
          'ballkan_v3'      => 'body table tr td[width="100%"][class^="font3"]',
          'ballkan_v4'      => 'body table tr td[class^="font1"]',
          'ballkan_v5'      => 'body table tr td[class^="font2"]',
          'ballkan_v6'      => 'body table tr div[class^="font"]',
          'top_channel_v1'  => 'span[class^="arial1"]',
          'top_channel_v2'  => 'span[class^="arial2"]',
          'top_channel_v3'  => 'span[class^="treb1"]',
          'zp'              => 'div[class*="article"]',
          'base'            => 'p',
          'strange'         => 'font'
      }

    @logger = Logger.new('log/redability.log')

      def parse(base)
        @logger.info("REDABILITY START=======================================")
        base.css('a, img').remove
        parse_paragraph_tags(base)

      end

    protected

    def parse_paragraph_tags(base)

      articles = nil
      ARTICLE_CSS.each_value{ |css_path|
        @logger.info css_path.inspect
        articles = base.css(css_path).map(&:parent).uniq
        @logger.info("ARTICLES  START=======================================")
        @logger.info articles.inspect
        @logger.info("ARTICLES END=======================================")
        if !articles.empty?
          break
        end
      }

      articles = articles.inject({}) do |hash, article|
        hash[article] = score(article)
        hash
      end

      article, score = articles.sort_by {|k,v| v }.last
      @logger.info("article : #{article}")
      @logger.info("score : #{score}")
      @logger.info("REDABILITY END=======================================")
      return unless article
      return unless score > 10

      article
    end

    def score(article)
      @logger.info("SCORE START=======================================")
      score = 0

      score -= 50 if article.attr('class') =~ NEGATIVE
      score -= 50 if article.attr('id') =~ NEGATIVE
      score += 25 if article.attr('class') =~ POSITIVE
      score += 25 if article.attr('id') =~ POSITIVE
      score += 25 if article.name == 'article'

      score +=  Math.sqrt(article.text.gsub(/\s+/, ' ').length)

      paragraphs = article.css('> p')
      score += 2 if paragraphs.text.length > 10
      score += paragraphs.text.split(',').length
      score += paragraphs.length

      @logger.info article.inspect
      @logger.info score.inspect
      @logger.info("SCORE END=======================================")

      score

    end
    end
  end
end