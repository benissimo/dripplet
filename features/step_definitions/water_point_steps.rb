Given /^I am a fully registered user$/ do
  @user = Factory(:user)
  @user.activate!
end

Then /^I see something not yet implemented$/ do
  raise "boom"
end

Given /^I sign in correctly$/ do
  visit logout_url
  visit login_url
  fill_in "login", :with=>@user.login
  fill_in "password", :with=>'password'
  begin
    click_button "commit"
  rescue
    save_and_open_page
    raise
  end
  #response.should be_redirect
  # TODO: revise this condition so it doesn't depend on specific text.
  #flash[:notice].should == "Logged in successfully"
end

Given /^I am signed in as a fully registered user$/ do
  steps %Q{
    Given I am a fully registered user
    Given I sign in correctly
  }
end

When /^I fill in the water point creation form and submit$/ do
 fill_in "Title", :with=>"title 1"
 fill_in "Note", :with=>"note 1"
 begin
   click_button "Create"
 rescue
   save_and_open_page
   raise
 end
end

Then /^a new water point is created$/ do
  flash[:notice].should == "WaterPoint loaded. Please confirm location to publish."
end

Then /^I arrive at the confirmation page$/ do
  response.should render_template('water_points/edit')
end

When /^I upload a valid photo with GPS$/ do
  attach_file "photo_file", File.join(Rails.root, 'public', 'images', 'foto.jpg'), "image/jpg"
end

When /^I upload a valid photo without GPS$/ do
  attach_file "photo_file", File.join(Rails.root, 'public', 'images', 'rails.png'), "image/png"
end

When /^I upload an invalid photo$/ do
  attach_file "photo_file", File.join(Rails.root, 'public', 'favicon.ico')
end

Then /^the GPS coordinates have been parsed$/ do
  response.should contain "GPS Coordinates parsed from photo."
end

Then /^the GPS coordinates are the defaults$/ do
  response.should_not contain "GPS Coordinates parsed from photo."
end

Then /^an error message warns me that the photo is invalid$/ do
  response.should contain 'There were problems with the following fields'
end

Then /^I am still on the water point creation page$/ do
  response.should render_template('water_points/new')
end

