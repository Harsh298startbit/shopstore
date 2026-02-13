class CreateProductVariants < ActiveRecord::Migration[6.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :variant_type
      t.string :value
      t.decimal :price
      t.integer :inventory_quantity

      t.timestamps
    end
  end
end
