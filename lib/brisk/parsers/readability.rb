# encoding: utf-8

require 'nokogiri'

module Brisk
  module Parsers
    module Readability
      extend self
      extend Encoding

      NEGATIVE = /(comment|meta|footer|footnote|info|before|stats)/
      POSITIVE = /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/

      REMOVE_TAG = 'h1, h2, h3, h4, h5, pre, code, before, stats, ul, link'
      REMOVE_CLASS = 'div div[class*="fontbox"], [class*="-meta"], body *[class*="header"], [class*="before"], body *[class*="stats"], [class*="date"], [class*="img"], [class="reader"], [class*="skip"], [class*="tools"], [class*="share"], [class*="history"]'
      REMOVE_ID = '[id*="error"], [id*="see-also"], [id*="article-image"], [id*="-meta"], [id*="before"], [id*="stats"], [id*="tools"], [id*="share"]'

      ARTICLE_CSS = {
          'shek' => 'div[class*="postim-text"]',
          'alt' => 'div[class*="article-body"]',
          'libero' => 'div[class*="article_body"]',
          'usmag1' => 'div[id*="article-body"]',
          'corriere' => 'div[class*="article-content"]',
          'techcru' => 'div[class*="article-entry"]',
          'sport' => 'div[class*="desc-article"]',
          'tmz3' => 'div[itemprop="articleBody"]',
          'corr1' => 'article',
          'panorama_v2' => 'div[id*="primary"]',
          'mess' => 'div[class*="articoloContent"]',
          'tmz1' => 'div[class*="post-content"]',
          'tmz2' => 'div[id*="post-content"]',
          'huff1' => 'div[class*="body_text"]',
          'binsider' => 'div [class*="intro-content"]',
          'nfl' => 'div [class="articleText"]',
          'shqiptarja' => 'div [id="content"]',
          'sot' => 'div [class~="content"]',
          'ballkan_v1' => 'body table tr td[width="100%"][class^="font1"]',
          'ballkan_v2' => 'body table tr td[width="100%"][class^="font2"]',
          'ballkan_v3' => 'body table tr td[width="100%"][class^="font3"]',
          'ballkan_v4' => 'body table tr td[class^="font1"]',
          'ballkan_v5' => 'body table tr td[class^="font2"]',
          'ballkan_v6' => 'body table tr div[class^="font"]',
          'top_channel_v1' => 'span[class^="arial1"]',
          'top_channel_v2' => 'span[class^="arial2"]',
          'top_channel_v3' => 'span[class^="treb1"]',
          'zp' => 'div[class*="article"]',
          'rep' => 'span[class*="article"]',
          'mess1' => 'div[class*="testoart"]',
          'mess2' => 'div[class*="corpo_articolo"]',
          'mess3' => 'div[class*="article"]',
          'mess4' => 'div[id*="testo"]',
          'mess4' => 'div[class*="testo"]',
          'mess5' => 'div[class*="articolo"]',
          'corr2' => 'div[id*="article"]',
          'shqipja' => 'div[class*="text"]',
          'panorama_v1' => 'div[class*="post"]',
          'base' => 'p',
          'strange' => 'font',
          'kohajone' => 'div[id*="onlyMessage"]'
      }

      @logger = Logger.new('log/redability.log')

      def parse(base)
        @logger.info("BEFORE REDABILITY CLEAN=======================================")
        @logger.info(base)
        base.css(REMOVE_TAG).remove
        base.css(REMOVE_CLASS).remove
        base.css(REMOVE_ID).remove
        base.css('img').remove
        @logger.info("AFTER REDABILITY CLEAN=======================================")
        @logger.info(base)
        @logger.info("REDABILITY START=======================================")
        parse_paragraph_tags(base)

      end

      protected

      def parse_paragraph_tags(base)

        articles = nil
        ARTICLE_CSS.each_value { |css_path|
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

        article, score = articles.sort_by { |k, v| v }.last
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
        @logger.info("class negative     #{score}")
        score -= 50 if article.attr('id') =~ NEGATIVE
        @logger.info("id negative     #{score}")
        score += 25 if article.attr('class') =~ POSITIVE
        @logger.info("class positive     #{score}")
        score += 25 if article.attr('id') =~ POSITIVE
        @logger.info("is positive     #{score}")
        score += 25 if article.name == 'article'
        @logger.info("name article     #{score}")
        score += Math.sqrt(article.text.gsub!(/\s+/, ' ').length)
        @logger.info("text length     #{score}")
        paragraphs = article.css('> p')
        score += 2 if paragraphs.text.length > 10
        @logger.info("par legth > 10     #{score}")
        score += paragraphs.text.split(',').length
        @logger.info("par text length     #{score}")
        score += paragraphs.length
        @logger.info("par length     #{score}")
        @logger.info article.inspect
        @logger.info score.inspect
        @logger.info("SCORE END=======================================")

        score

      end
    end
  end
end