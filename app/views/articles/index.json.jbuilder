json.array!(@articles) do |article|
  json.extract! article, :id, :title, :source_id, :pub_date, :summary, :string, :author, :image, :link
  json.url article_url(article, format: :json)
end
