# == Schema Information
# Schema version: 20100613162817
#
# Table name: groups
#
#  id              :integer(4)      not null, primary key
#  title           :string(255)     not null
#  lowercase_title :string(255)     not null
#  user_id         :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class Group < ActiveRecord::Base
  belongs_to :creator, :class_name =>'User', :foreign_key => 'user_id' #user_id refers to group creator
  validates_presence_of :user_id
  validates_presence_of :title
  validates_uniqueness_of :lowercase_title
  has_many :group_members, :include => :user, :dependent => :destroy, :conditions => "users.state = 'active'" #verified this cleans up group_members without removing users.

  #Add LIKE search method
  def before_save
    self.lowercase_title = self.title.mb_chars.downcase
  end
  
end
