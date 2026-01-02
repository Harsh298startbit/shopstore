class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :product_variants, through: :cart_items
  
  def total_price
    cart_items.includes(product_variant: :product).sum do |item|
      item.product_variant.price * item.quantity
    end
  end
  
  def total_items
    cart_items.sum(:quantity)
  end
end
