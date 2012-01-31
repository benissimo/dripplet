# == Schema Information
# Schema version: 20100613162817
#
# Table name: group_members
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  group_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

end
