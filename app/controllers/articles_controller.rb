# Controller for article
class ArticlesController < ApplicationController
  before_action :authenticate_user

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.paginate(page: params[:page], per_page: 10).order(pub_date: :desc)
  end

  def my_interests
    @articles = Article.tagged_with(current_user.interest_list, any: true).paginate(page: params[:page], per_page: 10).order(pub_date: :desc)
    render 'index'
  end

  def email_service
    @art_sent = Article.email(current_user)
    UserMailer.mail_article(@art_sent, current_user['email']).deliver
    redirect_to articles_path, notice: 'Email has been successfully sent.'
  end

  def search
    if params[:search]
      keyword_array = params[:search].split(' ')
      @articles = Article.search(keyword_array).paginate(page: params[:page], per_page: 10)
      render 'index'
    else
      redirect_to articles_path
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @article = Article.find(params[:id])
  end
end
