class User < ApplicationRecord
  has_secure_password validations: false
  
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_variants, through: :wishlist_items, source: :product_variant
  has_many :messages, dependent: :destroy
  has_many :admin_messages, class_name: 'Message', foreign_key: 'admin_id'
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  # Only validate password for non-OAuth users
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :password, presence: true, if: -> { provider.blank? && new_record? }
  
  before_save :downcase_email
  
  # OAuth: Create user from Google authentication
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.image = auth.info.image
      user.provider = auth.provider
      user.uid = auth.uid
      # Set a random password for OAuth users (required by has_secure_password)
      user.password = SecureRandom.hex(15)
      user.password_confirmation = user.password
    end
  end
  
  # Check if user signed up with OAuth
  def oauth_user?
    provider.present? && uid.present?
  end
  
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