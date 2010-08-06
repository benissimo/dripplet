#---
# Excerpted from "Advanced Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_arr for more book information.
#---

class UserService
  
  attr_reader :user, :avatar
  
  def initialize(user, avatar)
    @user = user
    @avatar = avatar
  end
  
  def save
    return false unless valid?
    begin
      user.transaction do
        if @avatar.new_record?
          @user.avatar.destroy if @user.avatar
          @avatar.user = @user
          @avatar.save!
        end
        @user.save!
        true
      end
    rescue
      false
    end
  end

  def valid?    
    @user.valid? && @avatar && @avatar.valid?
  end
  
  
  
  def update_attributes(user_attributes, avatar_file)
    @user.attributes = user_attributes
    unless avatar_file.blank?
      @avatar = Avatar.new(:uploaded_data => avatar_file)
    end
    save
  end
  
  

end

