class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :title, :null => false
      t.string :lowercase_title, :null => false
      t.integer :user_id

      t.timestamps
    end

    add_index :groups, :lowercase_title, :unique => true
  end

  def self.down
    drop_table :groups
  end
end
