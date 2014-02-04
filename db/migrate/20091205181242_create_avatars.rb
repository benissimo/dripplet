class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.integer :user_id, :parent_id, :size, :width, :height
      t.string  :content_type, :filename, :thumbnail
      t.timestamps
    end
    add_index :avatars, :user_id, :unique => false
  end

  def self.down
    drop_table :avatars
  end
end
