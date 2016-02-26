require 'open-uri'
require 'json'
require 'net/http'
require 'time'
# This class demonstrates an importer for The Guardian. After Scraping
# and interpreting the article info, all data will be store in database.
class GImporter
  def initialize
    source_name = 'The Guardian'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://content.guardianapis.com'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false

    request_url = '/search?api-key=5x7c2kvn7sy2pdf7srdu9nmk&show-fields=all'
    response = http.send_request('GET', request_url)

    result = JSON.parse(response.body)
    docs = result['response']['results']

    docs.each do |doc|
      articles << (interpret doc)
    end
    articles
  end

  private

  # Define a interpret method that interprets article data after it parsed
  def interpret(d)
    article = Article.new
    article.title = !d['webTitle'].nil? ? d['webTitle'] : 'n/a'
    article.source = @source
    article.pub_date = !d['webPublicationDate'].nil? ? (DateTime.parse d['webPublicationDate']) : nil
    article.author = !d['fields']['byline'].nil? ? d['fields']['byline'] : 'n/a'
    article.link = !d['webUrl'].nil? ? d['webUrl'] : 'n/a'

    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    summary = !d['fields']['body'].nil? ? d['fields']['body'] : 'n/a'
    summary.gsub!(re, '')
    article.summary = summary[0...126] + '...'

    article.image = !d['fields']['thumbnail'].nil? ? d['fields']['thumbnail'] : 'n/a'
    article
  end
end
