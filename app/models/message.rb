class Message < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id', optional: true
  
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(is_read: false) }
  scope :for_conversation, ->(user_id) { where(user_id: user_id).order(created_at: :asc) }
  
  after_create_commit :broadcast_message

  def sender
    sent_by_admin ? admin : user
  end

  def sender_name
    sent_by_admin ? (admin&.name || "Admin") : user.name
  end
  
  private
  
  def broadcast_message
    # Broadcast to the user's specific channel (e.g., chat_5)
    ActionCable.server.broadcast(
      "chat_#{user_id}",
      {
        id: id,
        content: content,
        sender_name: sender_name,
        sent_by_admin: sent_by_admin,
        created_at: created_at.strftime("%b %d at %I:%M %p"),
        message_html: ApplicationController.renderer.render(
          partial: 'messages/message',
          locals: { message: self }
        )
      }
    )
  end
end
