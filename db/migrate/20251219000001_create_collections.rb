class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :collections, :name, unique: true
  end
end
