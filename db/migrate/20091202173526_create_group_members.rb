class CreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
    add_index :group_members, [:user_id, :group_id], :unique => true
    add_index :group_members, :group_id, :unique => false
    add_index :group_members, :user_id, :unique => false
    
  end

  def self.down
    drop_table :group_members
  end
end
