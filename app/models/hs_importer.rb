require 'rss'
require 'open-uri'
# This class demonstrates an importer for The Herald Sun. After Scraping
# and interpreting the article info, all data will be store in database.
class HSImporter
  def initialize
    source_name = 'The Herald Sun'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://feeds.news.com.au/heraldsun/rss/heraldsun_news_sport_2789.xml'

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

    name = !i.source.nil? ? i.source.content : 'n/a'
    article.author = (name[0..2] == 'By ') ? name.slice(3..name.size) : name

    article.link = !i.link.nil? ? i.link : 'n/a'
    article.summary = !i.description.nil? ? i.description : 'n/a'
    article.image = (!i.enclosure.nil? && i.enclosure.type == 'image/jpeg') ? i.enclosure.url : 'n/a'  
    article
  end
end

