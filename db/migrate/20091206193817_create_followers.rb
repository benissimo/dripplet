class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers do |t|
      t.integer :user_id
      t.integer :water_point_id

      t.timestamps
    end
    add_index :followers, [:user_id, :water_point_id], :unique => true
    add_index :followers, :water_point_id, :unique => false
  end

  def self.down
    drop_table :followers
  end
end
