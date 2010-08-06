class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :water_point_id
      t.integer :user_id
      t.integer :rating

      t.timestamps
    end
    add_index :votes, [:water_point_id, :user_id], :unique => true
    add_index :votes, :water_point_id, :unique => false
  end

  def self.down
    drop_table :votes
  end
end
