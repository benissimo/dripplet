# == Schema Information
# Schema version: 20100613162817
#
# Table name: votes
#
#  id             :integer(4)      not null, primary key
#  water_point_id :integer(4)
#  user_id        :integer(4)
#  rating         :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :water_point

  validates_presence_of :rating
  validates_presence_of :water_point_id
  validates_presence_of :user_id

  named_scope :up, :conditions => {:rating => 1}
  named_scope :down, :conditions => {:rating => -1}

  after_save :update_vote_count
  after_destroy :update_vote_count
  before_save :prevent_vote_for_self


  def update_vote_count
    #credit for this approach: http://blog.eldoy.com/posts/14-Custom-counter-cache-column
    self.water_point.update_attributes :up_score => self.water_point.votes.up.count
    self.water_point.update_attributes :down_score => self.water_point.votes.down.count
    self.water_point.reload
    self.water_point.posted_by.update_attribute(:up_scores, self.water_point.posted_by.calculate_up_scores)
  end

  protected
  def prevent_vote_for_self
    if self.water_point.posted_by.id == self.user_id
      raise "Can't vote for one's own waterpoint."
    end

  end

end
