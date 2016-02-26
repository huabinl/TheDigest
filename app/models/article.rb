require 'will_paginate/array'
# Model for atricle, a corresponding table is build in database
class Article < ActiveRecord::Base
  belongs_to :source
  validates_uniqueness_of :title
  self.per_page = 10
  acts_as_taggable

  def self.email(user)
    # get intertest article id to an array
    current_user = user
    arts = Article.tagged_with(current_user.interest_list, any: true).order(pub_date: :desc).to_a
    articles_ids = []
    arts.each do |a|
      articles_ids << a[:id].to_s
    end
    # get at most 10 articles into mail database
    @art_sent = []
    mail_list = []
    if (!(Mails.where(user_id: user[:id]).to_a).nil?)
      all_mail = Mails.where(user_id: user[:id]).to_a
      all_mail.each do |mail|
        mail_list << mail['article_id']
      end
      count = 0
      articles_ids.each do |a_id|
        next unless (!(mail_list.include?(a_id)) && count < 10)
        new_mail(a_id, current_user[:id])
        add_sent_mail(a_id)
        count += 1
      end
    else
      count = 0
      while (count < 10)
        articles_ids.each do |a_id|
          new_mail(a_id, current_user[:id])
          add_sent_mail(a_id)
          count += 1
        end
      end
    end
    @art_sent
  end

  def self.search(keyword_array)
    # puts keywordArray
    atricles = Article.all.order(pub_date: :desc)
    results = {}
    key_ary = keyword_array.uniq.map(&:downcase)

    atricles.each do |item|
      tag_ary = item.tag_list.to_a.uniq.map(&:downcase)
      tag_result = tag_ary.count - (tag_ary - key_ary).count
      title_ary = item.title.split(' ').uniq.map(&:downcase)
      title_result = title_ary.count - (title_ary - key_ary).count
      summary_ary = item.summary.split(' ').uniq.map(&:downcase)
      summary_result = summary_ary.count - (summary_ary - key_ary).count
      source_ary = item.source.name.split(' ').uniq.map(&:downcase)
      source_result = source_ary.count - (source_ary - key_ary).count

      result = tag_result * 4.0 + title_result * 3.0 + summary_result * 2.0 + source_result * 1.0
      next unless result > 0
      if results.key?(result)
        results[result] << item
      else
        results[result] = [item]
      end
    end
    final_results = []
    results.keys.sort.reverse_each { |k| final_results.concat(results[k]) }
    final_results
  end

  private

  def self.new_mail(article_id, user_id)
    @mail = Mails.new
    @mail.article_id = article_id
    @mail.user_id = user_id
    @mail.save
  end

  def self.add_sent_mail(article_id)
    a = Article.find_by id: article_id
    @art_sent << a
  end
end
