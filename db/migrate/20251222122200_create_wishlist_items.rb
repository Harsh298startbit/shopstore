class CreateWishlistItems < ActiveRecord::Migration[6.1]
  def change
    create_table :wishlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :wishlist_items, [:user_id, :product_variant_id], unique: true, name: 'index_wishlist_on_user_and_variant'
  end
end
