xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "albanania"

    xml.description "Lajme, artikuj, opinione, biseda, ngjarje, diskutime. Gjithçka interesante zgjedhur nga lexuesit."
    xml.link "http://albanania.com/"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link post.url

        xml.description(%{
          #{post.summary}
          <p>
            <a href="#{post.url}">Lexo më shumë</a> |
            <a href="#{post.slug_url}">Komente</a>
          </p>
        })

        xml.pubDate post.published_at.rfc822
        xml.guid post.slug
      end
    end
  end
end