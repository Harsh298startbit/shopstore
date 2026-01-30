class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      cookies.encrypted[:user_id] = user.id  # Add this for Action Cable
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

  def destroy
    session[:user_id] = nil
    cookies.delete(:user_id)  # Add this to clear Action Cable cookie
    redirect_to root_path, notice: "Logged out successfully!"
  end

  private

  def redirect_if_logged_in
    if logged_in?
      redirect_to root_path, notice: "You are already logged in!"
    end
  end
end