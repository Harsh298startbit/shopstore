class Product < ApplicationRecord
  belongs_to :collection, optional: true
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  
  validates :name, presence: true
  validates :description, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  
  accepts_nested_attributes_for :product_variants, 
                                allow_destroy: true, 
                                reject_if: :all_blank
  
  scope :featured, -> { where(featured: true) }
  
  # Get the base/starting price from variants
  def base_price
    product_variants.minimum(:price) || 0
  end
  
  # Get price range if variants have different prices
  def price_range
    prices = product_variants.pluck(:price).compact.uniq.sort
    return "N/A" if prices.empty?
    return "$#{sprintf('%.2f', prices.first)}" if prices.length == 1
    
    "$#{sprintf('%.2f', prices.first)} - $#{sprintf('%.2f', prices.last)}"
  end
  
  def average_rating
    rating || 0
  end
  
  # Check if product has stock
  def in_stock?
    product_variants.sum(:inventory_quantity) > 0
  end
end