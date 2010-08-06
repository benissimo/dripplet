class CreateWaterPoints < ActiveRecord::Migration
  def self.up
    create_table :water_points do |t|
      t.string :title
      t.text :note
      t.decimal :lat, :precision=>15, :scale=>10
      t.decimal :lng, :precision=>15, :scale=>10
      t.integer :user_id
      t.integer :comments_count, :default => 0
      t.integer :up_score, :default => 0
      t.integer :down_score, :default => 0
      t.integer :visits, :default => 0
      t.boolean :confirmed, :default => false
      t.timestamps
    end
    add_index :water_points, :user_id
    add_index :water_points, :comments_count
    add_index :water_points, :up_score
    add_index :water_points, :down_score
    add_index :water_points, :visits
    add_index :water_points, :confirmed
  end

  def self.down
    drop_table :water_points
  end
end
