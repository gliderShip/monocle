# encoding: utf-8

require 'nokogiri'

module Brisk
  module Parsers
    module Readability extend self
      extend Encoding

      NEGATIVE = /(comment|meta|footer|footnote)/
      POSITIVE = /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/
      BAD_CLASS = 'div[class*="comment"], div[class*="Comment"],  div[class*="meta"], div[class*="foot"], div[class*="note"], div[class*="noprint"], span[class*="postinfo"], p[class*="caption"]'
      BAD_ID = 'div[id*="comment"], div[id*="Comment"], div[id*="meta"], div[id*="foot"], div[id*="note"], div[id*="noprint"]'

      ARTICLE_CSS  = {
          'panorama_v1'    => 'div[class*="post"]',
          'panorama_v2'    => 'div[id*="primary"]',
          'ballkan_v1'  => 'body table tr td[width="100%"][class^="font1"]',
          'ballkan_v2'  => 'body table tr td[width="100%"][class^="font2"]',
          'ballkan_v3'  => 'body table tr td[width="100%"][class^="font3"]',
          'ballkan_v4'  => 'body table tr td[class^="font1"]',
          'ballkan_v5'  => 'body table tr td[class^="font2"]',
          'ballkan_v6'  => 'body table tr div[class^="font"]',
          'top_channel_v1'  => 'span[class^="arial1"]',
          'top_channel_v2'  => 'span[class^="arial2"]',
          'top_channel_v3'  => 'span[class^="treb1"]',
          'base'        => 'p',
      }

      def parse(base)
        parse_paragraph_tags(base)
      end

    protected

    def parse_paragraph_tags(base)

      base.css('a, img, script, style, link, iframe, option, input', 'br', 'form').remove
      base.css(BAD_CLASS).remove
      base.css(BAD_ID).remove

      articles = nil
      ARTICLE_CSS.each_value{ |css_path|
        articles = base.css(css_path).map(&:parent).uniq
        break if !articles.empty?
      }

      articles = articles.inject({}) do |hash, article|
        hash[article] = score(article)
        hash
      end

      article, score = articles.sort_by {|k,v| v }.last
      return unless article
      return unless score > 10

      article
    end

    def score(article)
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

      score
    end
    end
  end
end