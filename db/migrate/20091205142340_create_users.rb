class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      #produced using:
      ### script/generate authenticated user sessions --include-activation --stateful
      ### NB: name field not used. safe to remove?
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :state,                     :string, :null => :no, :default => 'passive'
      t.column :deleted_at,                :datetime
      #added custom fields
      t.string :first_ip, :limit => 15, :null=>false
      t.string :last_ip, :limit => 15, :null=>false
      t.text   :note, :default=> '', :null=>true
      t.integer :water_points_count, :default=>0 #how many has user posted
      t.integer :up_scores, :default=>0 #sum of up_score for all water_points posted
      t.string :locale, :default=>'en'

    end
    add_index :users, :login, :unique => true
    add_index :users, :water_points_count, :unique => false
    add_index :users, :up_scores, :unique => false
  end

  def self.down
    drop_table "users"
  end
end
