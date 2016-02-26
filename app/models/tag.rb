# tagging module for add tags to article using 5 methods
class Tag
  def initialize
  end

  def tagging(articles)
    articles.each do |a|
      tags = []
      test_a = !a.title.nil? && !(a.title.eql? 'n/a') && !(a.title.eql? '')
      test_b = !a.summary.nil? && !(a.summary.eql? 'n/a') && !(a.summary.eql? '')
      next unless test_a
      info = test_b ? (a.title + '. ' + a.summary) : a.title
      tags << (sentimental info)
      tags.concat(alchemy info)
      tags.concat(indico info)
      tags.concat(eng_tagger info)
      tags.concat(open_calais info)
      a.tag_list = tags.uniq.join(', ')
      a.save
    end
  end

  private

  def open_calais(target)
    tags = []
    oc = OpenCalais::Client.new(api_key: 'IiomBkNPhy2jrDShnffQ37JzP9wfDIzG')
    oc_response = oc.enrich target
    unless oc_response.tags.nil?
      oc_response.tags.each { |t| (t[:score] > 0.9) ? (tags << t[:name]) : tags }
    end
    unless oc_response.topics.nil?
      oc_response.topics.each { |t| (t[:score] > 0.9) ? (tags << t[:name]) : tags }
    end
    tags
  end

  def sentimental(target)
    Sentimental.load_defaults
    Sentimental.threshold = 0.0
    s = Sentimental.new
    s.get_sentiment target
  end

  def alchemy(target)
    AlchemyAPI.key = '8719f95784fe901d584229db3d9122feefdac78c'
    tags = []
    a_entities = AlchemyAPI::EntityExtraction.new.search(text: target)
    unless a_entities.nil?
      a_entities.each { |e| (e['relevance'].to_f > 0.9) ? (tags << e['type'] << e['text']) : tags }
    end
    a_concepts = AlchemyAPI::ConceptTagging.new.search(text: target)
    unless a_concepts.nil?
      a_concepts.each { |c| (c['relevance'].to_f > 0.9) ? (tags << c['text']) : tags }
    end
    tags
  end

  def indico(target)
    Indico.api_key = 'd2c5f68dc1ca95d5ac0c850eadc97fd4'
    tags = []
    ind_keywords = Indico.keywords target
    unless ind_keywords.nil?
      ind_keywords.each { |k, v| (v > 0.5) ? (tags << k) : tags }
    end
    ind_tags = Indico.text_tags target
    ind_tags_sorted = ind_tags.sort_by { |_k, v| -1.0 * v }.first(5).to_h
    ind_tags_sorted.each { |k, v| (v > 0.5) ? (tags << k) : tags }
    tags
  end

  def eng_tagger(target)
    tgr = EngTagger.new
    tagged = tgr.add_tags(target)
    tags = tgr.get_proper_nouns(tagged).keys.first(3)
    tags
  end
end
