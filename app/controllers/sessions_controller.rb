
# Controller for session
class SessionsController < ApplicationController
  # Before actions to check paramters
  before_action :check_params, only: [:login]
  before_action :authenticate_user, only: [:logout]

  # Find a user with the username and password, log in that user if they exist
  def login
    # Find a user with params
    user = User.authenticate(@credentials[:username], @credentials[:password])
    if user
      # Save them in the session
      log_in user
      # Redirect to posts page
      redirect_to articles_path
    else
      redirect_to :back
    end
  end

  # Log out the user in the session and redirect to the unauth thing
  def logout
    log_out
    redirect_to login_path
  end

  private

  def check_params
    params.require(:credentials).permit(:username, :password)
    @credentials = params[:credentials]
  end
end
