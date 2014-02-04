# == Schema Information
# Schema version: 20100613162817
#
# Table name: comments
#
#  id             :integer(4)      not null, primary key
#  text           :text
#  water_point_id :integer(4)
#  user_id        :integer(4)
#  ip_addr        :string(255)
#  enabled        :boolean(1)      default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :water_point #water_points.comments_count filled via update_comment_count() method below
  belongs_to :author, :class_name => 'User', :foreign_key => "user_id"

  validates_presence_of :text
  validates_presence_of :water_point_id
  validates_presence_of :user_id

  named_scope :visible, :conditions => {:enabled => true }

  after_save :update_comment_count
  after_destroy :update_comment_count


  def update_comment_count
    #credit for this approach: http://blog.eldoy.com/posts/14-Custom-counter-cache-column
    self.water_point.update_attributes :comments_count => self.water_point.comments.visible.count
  end

end
