class BatchSupport < ActiveRecord::Migration
  def self.up
    add_column :users, :batch_id, :string
    add_index :users, :batch_id
    
    add_column :water_points, :batch_id, :string
    add_index :water_points, :batch_id
    
    add_column :water_points, :state, :string, :default=>"active"
    say_with_time "Updating water_point.state..." do
      WaterPoint.find(:all).each do |w|
        w.update_attribute :state, "active"
      end
    end
    change_column :water_points, :state, :string, :default=>"active", :null=>false
    add_index :water_points, :state

    add_column :water_points, :photo_url, :string
  end

  def self.down
    remove_column :users, :batch_id
    remove_index :users, :batch_id
    
    remove_column :water_points, :batch_id
    remove_index :water_points, :batch_id
    
    remove_column :water_points, :state
    remove_index :water_points, :state
    
    remove_column :water_points, :photo_url
  end
end
