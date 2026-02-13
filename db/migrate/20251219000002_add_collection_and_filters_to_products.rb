class AddCollectionAndFiltersToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :collection, foreign_key: true
    add_column :products, :category, :string
    add_column :products, :discount_percentage, :decimal, precision: 5, scale: 2, default: 0
  end
end
