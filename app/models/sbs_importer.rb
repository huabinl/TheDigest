require 'rss'
require 'open-uri'
# This class demonstrates an importer for SBS. After Scraping
# and interpreting the article info, all data will be store in database.
class SBSImporter
  def initialize
    source_name = 'SBS'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://www.sbs.com.au/news/rss/news/science-technology.xml'

    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        articles << (interpret item)
      end
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
