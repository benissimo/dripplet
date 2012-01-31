class FeedbackController < ApplicationController
  layout :choose_layout

  def report
    if params[:ref].blank?
      params[:ref] = request.referrer
    end
  end

  def deliver
    comment = params[:comment]
    email = params[:email]
    reason = params[:reason]
    ref = params[:ref]
    if !verify_recaptcha
      flash.now[:error] = t('flash.error.captcha_fail') # "CAPTCHA check failed. Please try again."
      render :action=>:report
    else
      delivery = FeedbackMailer.deliver_feedback(comment,email,reason,ref)
      if delivery
        flash[:notice] = t('flash.notice.feedback') #  "Your feedback has been delivered."
        redirect_to :action=>:thanks
      else
        flash.now[:error] = t('flash.error.feedback') # "Problem sending feedback. Please try again later."
        render :action=>:report
      end
    end
  end

  def thanks

  end

end
