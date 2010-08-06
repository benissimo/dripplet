class CommentObserver < ActiveRecord::Observer
  def after_create(comment)

    comment.reload
    #get list of followers
    @followers = Follower.find_all_by_water_point_id(comment.water_point_id)
    if @followers.blank?
      #nothing to do
    else
      #debugger
      @followers.each do |follower|
        CommentMailer.deliver_comment_notification(comment,comment.water_point,follower)
      end
    end
  end

end
