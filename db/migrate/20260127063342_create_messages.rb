# db/migrate/[timestamp]_create_messages.rb
class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :admin_id
      t.boolean :is_read, default: false
      t.boolean :sent_by_admin, default: false

      t.timestamps
    end
    
    add_index :messages, :admin_id
    add_index :messages, :is_read
    add_index :messages, :created_at
  end
end