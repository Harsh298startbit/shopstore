class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
  
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :variant_has_sufficient_inventory
  
  def subtotal
    product_variant.price * quantity
  end
  
  def product
    product_variant.product
  end
  
  private
  
  def variant_has_sufficient_inventory
    if product_variant && product_variant.inventory_quantity
      if quantity > product_variant.inventory_quantity
        errors.add(:quantity, "exceeds available inventory (#{product_variant.inventory_quantity} available)")
      end
    end
  end
end
