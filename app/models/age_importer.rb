require 'rss'
require 'open-uri'
# This class demonstrates an importer for The Age. After Scraping
# and interpreting the article info, all data will be store in database.
class AgeImporter
  def initialize
    source_name = 'The Age'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://feeds.theage.com.au/rssheadlines/entertainment.xml'

    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each { |item| articles << (interpret item) }
    end
    articles
  end

  private

  # Define a interpret method that interprets article data after it parsed
  def interpret(i)
    article = Article.new
    article.title = !i.title.nil? ? i.title : 'n/a'
    article.source = @source
    article.pub_date = !i.pubDate.nil? ? i.pubDate : nil
    article.author = 'n/a'
    article.link = !i.link.nil? ? i.link : 'n/a'

    description = !i.description.nil? ? i.description : 'n/a'
    if description.include? 'img src'
      p1 = description.index('http')
      p2 = description.index('.jpg"')
      article.image = description[p1, p2 - 9]
      p3 = description.rindex('>')
      p4 = description.rindex('.')
      article.summary = description[p3 + 1, p4].lstrip
    else
      article.image = 'n/a'
      article.summary = description
    end
    article
  end
end
