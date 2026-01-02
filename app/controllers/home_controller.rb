class HomeController < ApplicationController
  def index
 @products = Product.featured.limit(6)
  end

  def show
    
  end

  def new
  end
end
