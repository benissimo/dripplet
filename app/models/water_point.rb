# == Schema Information
# Schema version: 20100613162817
#
# Table name: water_points
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  note           :text
#  lat            :decimal(15, 10)
#  lng            :decimal(15, 10)
#  user_id        :integer(4)
#  comments_count :integer(4)      default(0)
#  up_score       :integer(4)      default(0)
#  down_score     :integer(4)      default(0)
#  visits         :integer(4)      default(0)
#  confirmed      :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#  batch_id       :string(255)
#  state          :string(255)     default("active"), not null
#  photo_url      :string(255)
#

class WaterPoint < ActiveRecord::Base
  
  acts_as_mappable
  
  has_many :comments, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :followers, :dependent => :destroy
  has_one :photo, :dependent => :destroy
  belongs_to :posted_by, :class_name => 'User', :foreign_key => "user_id"  
 
  ###### Easier to just delegate this to app flow. creation: lat/lng empty. confirm: provided from map. 
#  validates_presence_of :lat
#  validates_numericality_of :lat
#  validates_presence_of :lng
#  validates_numericality_of :lng

  validates_presence_of :title
  validates_presence_of :user_id
  
  named_scope :visible, :conditions => {:confirmed => true, :state => "active" }  
  named_scope :filo, :order => "created_at DESC"
  named_scope :with_photo, {:joins => :photo}
  
  after_save :update_wp_count
  after_destroy :update_wp_count

    #In case you need to update these manually. connect via script/console and then run:
    # User.all.each.map do |u|
    # u.water_points_count = u.water_points.visible.count
    # u.save
    # end
    
  def update_wp_count
    #credit for this approach: http://blog.eldoy.com/posts/14-Custom-counter-cache-column
    self.posted_by.update_attribute :water_points_count, self.posted_by.water_points.visible.count
  end
  
  def delete!
    self.update_attribute :state, "deleted"
  end
  
  def addr=(address)
    if address.nil? or address.length < 3
      #do nothing
    else
      geo = GeoKit::Geocoders::MultiGeocoder.geocode(address)
      errors.add(:address, "Could not geocode address") unless geo.success
      self.lat, self.lng = geo.lat, geo.lng if geo.success
    end
  end
  
  def addr
    #this method added for now just so csv-mapper won't complain. could add a reverse geocode call if this were ever needed.
    nil
  end
  
end
