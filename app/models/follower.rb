# == Schema Information
# Schema version: 20100613162817
#
# Table name: followers
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  water_point_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Follower < ActiveRecord::Base
  belongs_to :waterpoint
  belongs_to :user
end
