class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      create_session(user)
      @success = true
      @message = "Logged in successfully!"
      
      respond_to do |format|
        format.html { redirect_to user.admin? ? admin_root_path : root_path, notice: @message }
        format.js
      end
    else
      @success = false
      @message = "Invalid email or password"
      
      respond_to do |format|
        format.html do
          flash.now[:alert] = @message
          render :new, status: :unprocessable_entity
        end
        format.js
      end
    end
  end

  # Handle Google OAuth callback
  def omniauth
    auth = request.env['omniauth.auth']
    
    Rails.logger.info "=" * 80
    Rails.logger.info "OAuth callback received"
    Rails.logger.info "Provider: #{auth.provider}"
    Rails.logger.info "UID: #{auth.uid}"
    Rails.logger.info "Email: #{auth.info.email}"
    Rails.logger.info "Name: #{auth.info.name}"
    
    user = User.from_omniauth(auth)
    
    Rails.logger.info "User created/found: #{user.inspect}"
    Rails.logger.info "User persisted: #{user.persisted?}"
    
    if user.persisted?
      create_session(user)
      Rails.logger.info "Session created successfully"
      redirect_to root_path, notice: "Successfully logged in with Google!"
    else
      Rails.logger.error "User not persisted. Errors: #{user.errors.full_messages.join(', ')}"
      redirect_to login_path, alert: "Authentication failed: #{user.errors.full_messages.join(', ')}"
    end
  rescue => e
    Rails.logger.error "OAuth Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    redirect_to login_path, alert: "Authentication failed. Please try again."
  end

  # Handle OAuth failures
  def omniauth_failure
    Rails.logger.error "OAuth failure: #{params[:message]}"
    redirect_to login_path, alert: "Authentication failed. Please try again."
  end

  def destroy
    session[:user_id] = nil
    session[:cart_id] = nil
    cookies.delete(:user_id)
    redirect_to root_path, notice: "Logged out successfully!"
  end

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_to root_path, notice: "You are already logged in!"
    end
  end

  # Centralized session creation
  def create_session(user)
    session[:user_id] = user.id
    cookies.encrypted[:user_id] = user.id
  end
end