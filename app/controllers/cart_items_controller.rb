class CartItemsController < ApplicationController
  before_action :require_login

  def create
    @cart = current_cart
    product_variant = ProductVariant.find(params[:product_variant_id])
    
    # Check if item already exists in cart
    @cart_item = @cart.cart_items.find_by(product_variant: product_variant)
    
    if @cart_item
      # Update quantity
      @cart_item.quantity += params[:quantity].to_i
      @saved = @cart_item.save
      @message = @saved ? "Item quantity updated in cart" : @cart_item.errors.full_messages.join(", ")
    else
      # Create new cart item
      @cart_item = @cart.cart_items.build(
        product_variant: product_variant,
        quantity: params[:quantity].to_i
      )
      
      @saved = @cart_item.save
      @message = @saved ? "Item added to cart successfully" : @cart_item.errors.full_messages.join(", ")
    end

    respond_to do |format|
      if @saved
        format.html { redirect_to cart_path, notice: @message }
        format.js
      else
        format.html { redirect_back fallback_location: root_path, alert: @message }
        format.js
      end
    end
  end

  def update
    @cart = current_cart
    @cart_item = @cart.cart_items.find(params[:id])
    
    if @cart_item.update(quantity: params[:quantity])
      @message = "Quantity updated"
      respond_to do |format|
        format.html { redirect_to cart_path, notice: @message }
        format.js
      end
    else
      @message = @cart_item.errors.full_messages.join(", ")
      respond_to do |format|
        format.html { redirect_to cart_path, alert: @message }
        format.js
      end
    end
  end

  def destroy
    @cart = current_cart
    @cart_item = current_cart.cart_items.find(params[:id])
    @cart_item.destroy
    @message = "Item removed from cart"
    
    respond_to do |format|
      format.html { redirect_to cart_path, notice: @message }
      format.js
    end
  end
end
