require 'rss'
require 'open-uri'
# This class demonstrates an importer for ABC NEWS. After Scraping
# and interpreting the article info, all data will be store in database.
class ABCImporter
  def initialize
    source_name = 'ABC NEWS'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://www.abc.net.au/sport/syndicate/sport_all.xml'

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
    article.summary = !i.description.nil? ? i.description : 'n/a'    
    article.image = 'n/a'    
    article
  end
end
