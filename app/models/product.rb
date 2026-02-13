class Product < ApplicationRecord
  belongs_to :collection, optional: true
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  # Maximum file size for product images (5MB)
  MAX_IMAGE_SIZE = 5.megabytes

  # Allowed content types for product images
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/jpg image/png image/webp image/gif].freeze

  validates :name, presence: true
  validates :description, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

  # Validate image file type
  validate :validate_image_type

  # Validate image file size
  validate :validate_image_size
  
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

  private

  def validate_image_type
    return unless image.attached?

    unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
      errors.add(:image, 'must be a JPEG, PNG, WebP, or GIF image')
    end
  end

  def validate_image_size
    return unless image.attached?

    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "size must be less than #{MAX_IMAGE_SIZE / 1.megabyte}MB")
    end
  end
end
