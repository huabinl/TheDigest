require 'open-uri'
require 'json'
require 'net/http'
require 'time'
# This class demonstrates an importer for The New York Times. After Scraping
# and interpreting the article info, all data will be store in database.
class NYTImporter
  def initialize
    source_name = 'The New York Times'
    @source = Source.find_by name: source_name
  end

  # Define a scrape method that saves data
  def scrape
    articles = []
    url = 'http://api.nytimes.com'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false

    key = 'api-key=c12cb16541dce28040f58db4a5e139d6%3A17%3A72711388'

    request_url = '/svc/search/v2/articlesearch.json?' + key
    response = http.send_request('GET', request_url)

    result = JSON.parse(response.body)
    docs = result['response']['docs']

    docs.each do |doc|
      articles << (interpret doc)
    end
    articles
  end

  private

  # Define a interpret method that interprets article data after it parsed
  def interpret(d)
    article = Article.new

    if d['headline'] != []
      if !d['headline']['main'].nil?
        article.title = d['headline']['main']
      elsif !d['headline']['name'].nil?
        article.title = d['headline']['name']
      end
    end
    if article.title.nil?
      article.title = 'n/a'
    end

    article.source = @source
    article.pub_date = !(d['pub_date'].eql? '') ? (DateTime.parse d['pub_date']) : nil

    byline = (d['byline'] != []) ? d['byline']['original'] : 'n/a'
    article.author = (byline[0..2] == 'By ') ? byline[3..byline.size] : byline

    article.link = !(d['web_url'].eql? '') ? d['web_url'] : 'n/a'
    article.summary = !(d['snippet'].eql? '') ? d['snippet'] : 'n/a'

    # an article may contain several images
    image = []
    if d['multimedia'] != []
      url = 'http://www.nytimes.com/'
      img = d['multimedia']
      img.each { |i| (i['type'] == 'image') ? image << (url + i['url']) : 'n/a' }
    else
      image << 'n/a'
    end
    article.image = image.join(',')

    article
  end
end
