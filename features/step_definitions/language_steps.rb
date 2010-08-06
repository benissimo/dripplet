Given /^I registered via the italian version of the site$/ do
  @user = Factory(:user, :locale => 'it')
  ActionMailer::Base.deliveries.clear
end

When /^I fill in the forgot password form correctly and click submit$/ do
  fill_in "Login", :with=>@user.login
  fill_in "Email", :with=>@user.email
  click_button "Request a new password"
end

Then /^a password reminder message is sent$/ do
  response.should send_email
end

Then /^the password reminder message is in italian$/ do
  ActionMailer::Base.deliveries.last.subject.should contain 'Ecco'

end

Then /^the site is in english$/ do
  I18n.locale.should == 'en'
end