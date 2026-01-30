class User < ApplicationRecord
  has_secure_password
  
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_variants, through: :wishlist_items, source: :product_variant
  has_many :messages, dependent: :destroy
  has_many :admin_messages, class_name: 'Message', foreign_key: 'admin_id'
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  before_save :downcase_email
  
  def admin?
    is_admin == true
  end
  
  def customer?
    !is_admin
  end
  
  def unread_messages_count
    messages.unread.where(sent_by_admin: true).count
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end