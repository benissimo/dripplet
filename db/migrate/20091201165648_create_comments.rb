class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :text
      t.integer :water_point_id
      t.integer :user_id
      t.string :ip_addr
      t.boolean :enabled, :default=>true

      t.timestamps      
    end
    add_index :comments, :user_id, :unique => false
    add_index :comments, :water_point_id , :unique=> false
  end

  def self.down
    drop_table :comments
  end
end
