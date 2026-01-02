class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      @success = true
      @message = "Logged in successfully!"
      
      respond_to do |format|
        format.html { redirect_to root_path, notice: @message }
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
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
