# frozen_string_literal: true

class SessionsController < ApplicationController
  include SessionHelper
  skip_before_action :require_login, only: %i[omniauth login_local]

  def logout
    reset_session
    redirect_to home_path, alert: 'You are logged out.'
  end

  def omniauth
    auth = request.env['omniauth.auth']
    @user = find_or_create_user(auth)

    if @user.valid?
      session[:user_id] = @user.id
      redirect_to user_path(@user), notice: 'You are logged in.'
    else
      redirect_to home_path, alert: 'Login failed.'
    end
  end

  def login_local
    unless local_auth_enabled?
      redirect_to home_path, alert: 'Local login is disabled.'
      return
    end

    username = params[:username].to_s.strip.downcase
    password = params[:password].to_s
    user = User.where('LOWER(username) = ?', username).first

    if user&.local_auth? && user.authenticate(password)
      session[:user_id] = user.id
      redirect_to user_path(user), notice: 'You are logged in.'
    else
      redirect_to home_path, alert: 'Invalid username or password.'
    end
  end
end
