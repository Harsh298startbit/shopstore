class ProductVariant < ApplicationRecord
  belongs_to :product
  
  validates :variant_type, presence: true
  validates :value, presence: true
  validates :variant_type, uniqueness: { scope: [:product_id, :value], 
                                         message: "and value combination already exists for this product" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :product, presence: true
  validates :inventory_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Scope for in-stock variants
  scope :in_stock, -> { where('inventory_quantity > 0') }
  
  # Display name for variant
  def display_name
    "#{variant_type}: #{value}"
  end
end