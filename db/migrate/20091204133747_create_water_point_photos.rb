class CreateWaterPointPhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :water_point_id, :parent_id, :size, :width, :height
      t.string  :content_type, :filename, :thumbnail 
      t.timestamps
    end
    add_index :photos, :water_point_id, :unique => false
  end

  def self.down
    drop_table :photos
  end
end