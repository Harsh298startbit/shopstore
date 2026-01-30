class ChatChannel < ApplicationCable::Channel
  def subscribed
    user = User.find_by(id: params[:user_id])
    if user
      stream_from "chat_#{user.id}"
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
  
  def receive(data)
    user = User.find_by(id: data['user_id'])
    return unless user
    
    message = Message.new(
      user_id: data['user_id'],
      content: data['content'],
      sent_by_admin: data['sent_by_admin'] || false,
      admin_id: data['admin_id']
    )
    
    if message.save
      # Broadcast is handled by after_create_commit callback
    end
  end
end