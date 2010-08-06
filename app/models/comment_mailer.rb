class CommentMailer < ActionMailer::Base

  layout 'mailer' #use mailer.text.(html|plain).erb as the layout
  
  # call once per follower (do offline if need to scale. use delayed_job's "send_later")
  def comment_notification(comment, water_point, follower)
    setup_email(comment, water_point, follower)
    @subject += I18n.t 'mailer.comment_notify.subject'

  
    @body[:url]  = "http://www.dripplet.com/#{@locale}/water_points/#{water_point.id}"
    
  end
  
  protected
    def setup_email(comment, water_point, follower)
      @recipients  = "#{follower.user.email}"
      @from        = "noreply@dripplet.com"
      @subject     = "Dripplet.com "
      @sent_on     = Time.now
      @body[:comment] = comment
      @body[:to] = @recipients
      @locale = I18n.locale = follower.user.locale
    end
end
