class WishlistItemsController < ApplicationController
  before_action :require_login

  def index
    @wishlist_items = current_user.wishlist_items.includes(product_variant: { product: :image_attachment })
  end

  def create
    product_variant = ProductVariant.find(params[:product_variant_id])
    @wishlist_item = current_user.wishlist_items.find_or_initialize_by(product_variant: product_variant)
    
    if @wishlist_item.persisted?
      @message = "Item already in wishlist"
      @success = false
    elsif @wishlist_item.save
      @message = "Item added to wishlist"
      @success = true
    else
      @message = @wishlist_item.errors.full_messages.join(", ")
      @success = false
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: @message }
      format.js
    end
  end

  def destroy
    @wishlist_item = current_user.wishlist_items.find(params[:id])
    @wishlist_item.destroy
    @message = "Item removed from wishlist"
    
    respond_to do |format|
      format.html { redirect_back fallback_location: wishlist_items_path, notice: @message }
      format.js
    end
  end
end
