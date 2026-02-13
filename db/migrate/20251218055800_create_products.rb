class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :rating
      t.boolean :featured

      t.timestamps
    end
  end
end
