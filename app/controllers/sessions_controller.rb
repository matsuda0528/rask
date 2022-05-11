class SessionsController < ApplicationController
  def new
  end

  def create
    auth = request.env["omniauth.auth"]

    unless auth.credentials.active_member?
      render plain: "Unauthorized", status: 401
      return false
    end

    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    log_in user
    redirect_to projects_url
  end

  def destroy
    log_out
    redirect_to projects_url
  end

  def guest_sign_in
    user = User.create! do |u|
      u.name = 'Guest'
    end

    log_in user
    redirect_to '/', notice: 'Logged in as Guest User'
  end

end
