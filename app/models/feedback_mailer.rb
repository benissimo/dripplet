class FeedbackMailer < ActionMailer::Base

  layout 'mailer' #use mailer.text.(html|plain).erb as the layout
  
  # call once per follower (do offline if need to scale. use delayed_job's "send_later")
  def feedback(comment, email, reason, ref)
    setup_email(comment, email, reason)
    @subject    += reason
  
    @body[:url]  = ref
  
  end
  
  protected
    def setup_email(comment, email, reason)
      @recipients  = "info@madeintomorrow.com"
      @from        = "noreply@dripplet.com"
      if email
        @reply_to = email
      end
      @subject     = "Dripplet.com feedback:"
      @sent_on     = Time.now
      @body[:comment] = comment
      @body[:to] = @recipients
      @locale = I18n.locale
      #leave locale at whatever the site is currently using...
    end
end
