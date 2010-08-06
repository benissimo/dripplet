class GroupMailer < ActionMailer::Base
  
  layout 'mailer' #use mailer.text.(html|plain).erb as the layout

  # call once per member (do offline if need to scale. use delayed_job's "send_later")
  def message_to_group(message, group, member, sender)
    setup_email(message, group, member, sender)
    
    @subject += I18n.t 'mailer.group_notify.subject', :title=>group.title, :from=>sender.login    
    #@subject    += 'Message to group '+group.title+' from '+sender.login
  
    @body[:url]  = "http://www.dripplet.com/#{@locale}/groups/#{group.id}"
  
  end
  
  protected
    def setup_email(message, group, member, sender)
      @recipients  = "#{member.user.email}"
      @from        = "noreply@dripplet.com"
      @subject     = "Dripplet.com "
      @sent_on     = Time.now
      @body[:message] = message
      @body[:sender] = sender.login
      @body[:group] = group
      @body[:to] = @recipients
      @locale = I18n.locale = member.user.locale
    end
end
