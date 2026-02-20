# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_admin!, except: [:stop_impersonate]
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.all
    # Search functionality
    return unless params[:search]

    @users = @users.where('first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR username LIKE ?',
                          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_index_url, notice: 'User was successfully created'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_index_url, notice: 'User was successfully updated'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_index_url, notice: 'User was successfully deleted'
  end

  def import
    file = params[:file]
    return redirect_to admin_index_path, alert: 'No file uploaded' if file.nil?
    return redirect_to admin_index_path, alert: 'File not a CSV' unless file.content_type == 'text/csv'

    errors = IngestRosterFile.new.ingest_roster_file(file)
    if !errors.empty?
      redirect_to admin_index_path, notice: 'Users Imported', alert: errors
    else
      redirect_to admin_index_path, notice: 'Users Imported'
    end
  end

  def impersonate
    impersonated_user = User.find(params[:id])
    if impersonated_user
      session[:admin_id] = current_user.id if session[:admin_id].blank?
      session[:user_id] = impersonated_user.id
      redirect_to user_path(impersonated_user), notice: "You are now impersonating #{impersonated_user.email}."
    else
      redirect_to admin_index_path, alert: 'User not found'
    end
  end

  def stop_impersonate
    if session[:admin_id]
      admin_user = User.find(session[:admin_id])
      session[:user_id] = admin_user.id
      redirect_to user_path(admin_user), notice: "Impersonation stopped, logged back in as #{admin_user.email}"
    else
      redirect_to dashboard_path, alert: 'Not currently impersonating any user'
    end
  end

  private

  def authenticate_admin!
    return if current_user&.admin_flag?

    redirect_to dashboard_path, alert: 'You are not authorized to access this page.'
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params[:user][:provider] ||= 'google_oauth2'
    # Admin-created Google users are preloaded and linked on first OAuth login.
    if params[:user][:provider] == 'google_oauth2' && @user&.uid.blank?
      params[:user][:provider] = 'preloaded_google'
    end

    permitted = params.require(:user).permit(
      :first_name, :last_name, :email, :unit_id, :provider, :admin_flag,
      :username, :password, :password_confirmation
    )

    permitted.except(:password, :password_confirmation).tap do |attrs|
      attrs[:password] = permitted[:password] if permitted[:password].present?
      attrs[:password_confirmation] = permitted[:password_confirmation] if permitted[:password_confirmation].present?
    end
  end
end
