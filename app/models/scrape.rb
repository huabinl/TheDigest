# scraping module for getting news from 7 sources
class Scrape
  def initialize
    age ||= AgeImporter.new
    g ||= GImporter.new
    hs ||= HSImporter.new
    nyt ||= NYTImporter.new
    sbs ||= SBSImporter.new
    smh ||= SMHImporter.new
    abc ||= ABCImporter.new
    @importers = [abc, age, g, hs, sbs, nyt, smh]
  end

  def scrape
    new_articles = []
    @importers.each { |i| new_articles.concat(i.scrape) }
    new_articles
  end
end
