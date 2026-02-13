class CartsController < ApplicationController
  before_action :require_login

  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(product_variant: { product: :image_attachment })
  end

  def clear
    current_cart.cart_items.destroy_all
    redirect_to cart_path, notice: "Cart cleared successfully"
  end
end
