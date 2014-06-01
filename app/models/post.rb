#encoding: UTF-8
require 'sanitize/config/liberal'
require 'open-uri'

module Brisk
  module Models
    # noinspection RubyInterpreterInspection
    class Post < Sequel::Model
      # Scopes

      dataset_module do
        def ranked
          order(:score.desc, :published_at.desc)
        end

        def ordered
          dataset = self

          order(:published_at.desc)
        end

        def update_scores(votes, published_at, now)
          # g - Gravity
          # w - Weight of Votes compared to hour
          # p - Votes
          # t - Post age in hours
          # score = p*weight / (t+1)

          post_hour_epoch = published_at.extract('epoch')/3600
          w = 5.0
          t = now - post_hour_epoch

          return votes*w/(t + 1.0)
        end

        def rescore
          now = Sequel.lit('NOW()').extract('epoch') / 3600
          order(:score.desc).limit(200).update(:score => update_scores(:votes, :published_at, now))
        end

        def popular
          order(:score.desc)
        end

        def newest
          order(:published_at.desc)
        end

        def published
          where(~:published_at => nil).limit(200)
        end

        def search(query)
          query = "%#{query}%"
          ordered.where(:title.ilike(query) | :url.ilike(query))
        end

        def today
          published.where { published_at > 1.day.ago }
        end

        def tweetable
          today.ranked.where(tweet_id: nil).where {|p| p.votes > 6 }
        end

        def url(value)
          if value && !value.match(/\Ahttps?:\/\//)
            value = "http://#{value}"
          end

          where(url: value)
        end

        def paginate(ignore = nil, limit = 20)
          dataset = self

          if ignore
            dataset = dataset.exclude(:id => Array(ignore))
          end

          dataset.limit(limit)
        end

        def ignore(ignore = nil)
          dataset = self

          if ignore
            dataset = dataset.exclude(:id => Array(ignore))
          end
          dataset.limit(1000)
        end

      end

      # Relationships

      many_to_one :user
      one_to_many :comments, :on_delete => :cascade
      one_to_many :post_votes, :on_delete => :cascade
      one_to_many :post_visits, :on_delete => :cascade

      many_to_many :voted_users,
        :join_table => :post_votes,
        :class      => 'Brisk::Models::User',
        :left_key   => :post_id,
        :right_key  => :user_id,
        :on_delete => :cascade

      many_to_many :visited_users,
        :join_table => :post_visits,
        :class      => 'Brisk::Models::User',
        :left_key   => :post_id,
        :right_key  => :user_id,
        :on_delete  => :cascade

      # Plugins

      serialize_attributes :json, :oembed
      serialize_attributes :json, :link_icons
      serialize_attributes :json, :open_graph
      serialize_attributes :pg_uuid_array, :voted_user_ids

      # Attributes

      set_allowed_columns :title, :url

      attr_accessor :notify

      def url=(value)
        # Ensure URLS always begin with http://
        if value && !value.match(/\Ahttps?:\/\//)
          value = "http://#{value}"
        end

        super(value)
      end

      def calculate_score
        # w - Weight of votes compared to hour
        # p - Votes
        # score = p*w / (t+1)
        #
        w = 5.0
        now = Time.now.to_i
        p = votes

        sec = now - ( published_at || created_at || now).to_i
        t = sec / 3600.0 # .0 for float conversion
        score = (p*w) / (t+1.0)
        self.score = score
        score
      end

      def vote!(user)
        if voted?(user) and !user.admin?
          raise Sequel::ValidationFailed, 'User already voted'
        end

        self.add_voted_user(user)
        self.this.update(:votes => :votes + 1)
        self.user.karma!

        reload
        calculate_score
        save!
      end

      def voted?(user)
        voted_user_ids.include?(user.id)
      end

      def visited?(user)
        visited_users.include?(user)
      end

      def visit!(user)
        self.add_visited_user(user) if user
        self.this.update(:visits => :visits + 1)
      end

      def publish!
        self.published_at = Time.current
        calculate_score
        save!
      end

      def validate
        set_user_handle
        set_published_at
        set_slug
        set_domain
        validates_presence [:title, :url, :slug, :user_id]
        validates_unique [:url, :slug]
        validates_url :url
      end

      def retrieve!
        ourl      = open(url)
        html      = ourl.read
        html = Parsers::Encoding.encode(html)
        document  = Nokogiri::HTML(html, nil, nil)

        #document.meta_encoding()
        document         = Parsers::Skim.parse(document)
        microdata = Parsers::Schemaorg.parse(document)
        self.open_graph  = Parsers::OpenGraph.parse(document, true)
        self.oembed      = Parsers::OEmbed.parse(document)
        self.oembed['src'] = self.oembed['src'] || self.open_graph['v:src'] || microdata['videoUrl']

        if !self.oembed['src'].to_s.include?("www") && self.oembed['src'].to_s.start_with?('/') && !self.oembed['src'].to_s.start_with?('//')
          self.oembed['src'] = URI.parse(url).scheme + "://" + URI.parse(url).host + self.oembed['src']
        end

        self.html_title  = microdata['headline'] || self.open_graph['og:title'] || Parsers::HTMLTitle.parse(ourl)
        self.preview_url = self.open_graph['og:image'] || microdata['image'] || Parsers::Preview.parse(document)

        read_parsed      = Parsers::Readability.parse(document)
        o_description = self.open_graph['og:description'].to_s
        m_description = microdata['description'].to_s
        description      = o_description.length > m_description.length ? o_description : m_description
        description = description[0..300]
        psummary         = Parsers::Summary.parse(read_parsed, nil)
        self.summary     = microdata['articleBody'] || (psummary.to_s.length > description.to_s.length ? psummary : description)
        self.summary.gsub!(/\s+/, " ").to_s.strip!
        self.body        = read_parsed.inner_text.strip || ''

          self.link_icons  = Parsers::LinkIcon.parse(document)

        self.save
      end

      def slug_url
        "http://glidership.com:3000/posts/#{slug}"
      end

      def safe_body
        Sanitize.clean(body, Sanitize::Config::LIBERAL)
      end

      def preview_url
        super && URI.join(URI.escape(url), URI.escape(super)).to_s
      end

      def link_icon_url
        return unless link_icons
        icon = link_icons.sort_by {|l| l[:width] || 0 }.last
        icon && URI.join(url, icon[:href]).to_s
      end

      def notify?
        !!notify
      end

      def as_json(options = nil)
        user = (options || {})[:user]

        {
          id:             id,
          votes:          votes,
          voted:          user && voted?(user),
          created:        user && self.user_id == user.id,
          score:          score,
          title:          title,
          url:            url,
          oembed:         oembed,
          slug:           slug,
          domain:         domain,
          summary:        summary,
          preview_url:    preview_url,
          link_icon_url:  link_icon_url,
          comments_count: comments_count,
          user_id:        user_id,
          user_handle:    user_handle,
          created_at:     published_at || created_at
        }
      end

      protected

      def set_user_handle
        unless user_handle
          self.user_handle = user.handle
        end
      end

      def set_published_at
        self.published_at ||= Time.current
      end

      def set_slug
        return unless title
        return if slug

        initial = title.parameterize
        attempt = initial.dup
        count   = 0

        while Post[slug: attempt]
          count  += 1
          attempt = initial + "-#{count}"
        end

        self.slug = attempt
      end

      def set_domain
        return if domain
        self.domain = URI.parse(url).host if url
        self.domain.gsub!(/\Awww\./, '')  if self.domain
      end


    end
  end
end
