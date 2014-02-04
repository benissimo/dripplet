class UserMailer < ActionMailer::Base

  layout 'mailer' #use mailer.text.(html|plain).erb as the layout

  def signup_notification(user)
    setup_email(user)
    @subject += I18n.t 'mailer.signup.subject'

    @body[:url]  = "http://www.dripplet.com/#{user.locale}/activate/#{user.activation_code}"

  end

  def activation(user)
    setup_email(user)
    @subject += I18n.t 'mailer.activated.subject'
    @body[:url]  = "http://www.dripplet.com/#{user.locale}"

  end

  def new_password(user,pass)
    logger.info("user_mailer.send_new_password called")
    setup_email(user)
    @subject += I18n.t 'mailer.forgot_password.subject'
    @body[:pass] = pass
    @body[:url] = "http://www.dripplet.com/#{user.locale}/login"
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@dripplet.com"
      @subject     = "Dripplet.com "
      @sent_on     = Time.now
      @body[:user] = user
      @body[:to] = @recipients
      @locale = I18n.locale = user.locale
    end
end
