class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.includes(:product_variants).all
  end

  def show
  end

  def new
    @product = Product.new
    @product.product_variants.build
  end

  def edit
    @product.product_variants.build if @product.product_variants.empty?
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: 'Product created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Product deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :rating,
      :featured,
      :image,
      :collection_id,
      :category,
      :discount_percentage,
      product_variants_attributes: [
        :id,
        :variant_type,
        :value,
        :price,
        :inventory_quantity,
        :_destroy
      ]
    )
  end
end
