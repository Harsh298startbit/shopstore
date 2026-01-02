class User < ApplicationRecord
  has_secure_password
  
  has_many :carts, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_variants, through: :wishlist_items, source: :product_variant
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  before_save :downcase_email
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
