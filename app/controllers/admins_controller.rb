# Controller for admin commond
class AdminsController < ApplicationController
  # GET /admin/scrape
  def scrape
    # scraping module
    scraper ||= Scrape.new
    new_articles = scraper.scrape

    # tagging module
    tagger ||= Tag.new
    tagger.tagging new_articles

    redirect_to articles_path
  end

  def email
    @users = User.where(email_service: true)
    @users.each do |user|
      @art_sent = Article.email(user)
      UserMailer.mail_article(@art_sent, user['email']).deliver
    end
    redirect_to articles_path, notice: 'Email has been successfully sent.'
  end
end
