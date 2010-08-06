#---
# Excerpted from "Advanced Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_arr for more book information.
#---

class WaterPointService
  
  attr_reader :water_point, :photo
  
  def initialize(water_point, photo)
    @water_point = water_point
    @photo = photo
  end
  
  def save
    return false unless valid?
    begin
      water_point.transaction do
        if @photo.new_record?
          @water_point.photo.destroy if @water_point.photo
          @photo.water_point = @water_point
          @photo.save!
        end
        @water_point.save!
        true
      end
    rescue
      false
    end
  end

  def valid?
    @water_point.valid? && @photo && @photo.valid?
  end
  
  
  
  def update_attributes(water_point_attributes, photo_file)
    @water_point.attributes = water_point_attributes
    unless photo_file.blank?
      @photo = Photo.new(:uploaded_data => photo_file)
    end
    save
  end
  
  

end

