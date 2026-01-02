class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :product_variant
  
  validates :user_id, uniqueness: { scope: :product_variant_id, message: "has already added this item to wishlist" }
  
  def product
    product_variant.product
  end
end
