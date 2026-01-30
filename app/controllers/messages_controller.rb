class MessagesController < ApplicationController
  before_action :require_login
  
  def index
    unless current_user.admin?
      redirect_to chat_path and return
    end
    
    # Admin sees all conversations
    @conversations = User.where(is_admin: [false, nil])
                          .includes(:messages)
                          .select('users.*')
                          .sort_by { |user| user.messages.maximum(:created_at) || Time.at(0) }
                          .reverse
  end
  
  def show
    unless current_user.admin?
      redirect_to chat_path and return
    end
    
    @chat_user = User.find(params[:id])
    @messages = Message.for_conversation(@chat_user.id)
    
    # Mark messages as read
    Message.where(user_id: @chat_user.id, sent_by_admin: false, is_read: false)
           .update_all(is_read: true)
  end
  
  def create
    @message = Message.new(message_params)
    
    if current_user.admin?
      @message.admin_id = current_user.id
      @message.sent_by_admin = true
    else
      @message.user_id = current_user.id
      @message.sent_by_admin = false
    end
    
    respond_to do |format|
      if @message.save
        format.json { head :ok }
        format.html { redirect_back(fallback_location: root_path) }
      else
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_back(fallback_location: root_path, alert: 'Error sending message') }
      end
    end
  end
  
  def chat
    unless current_user.customer?
      redirect_to messages_path and return
    end
    
    @messages = Message.for_conversation(current_user.id)
    
    # Mark admin messages as read
    Message.where(user_id: current_user.id, sent_by_admin: true, is_read: false)
           .update_all(is_read: true)
  end
  
  private
  
  def message_params
    params.require(:message).permit(:content, :user_id)
  end
end