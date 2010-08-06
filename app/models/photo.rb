# == Schema Information
# Schema version: 20100613162817
#
# Table name: photos
#
#  id             :integer(4)      not null, primary key
#  water_point_id :integer(4)
#  parent_id      :integer(4)
#  size           :integer(4)
#  width          :integer(4)
#  height         :integer(4)
#  content_type   :string(255)
#  filename       :string(255)
#  thumbnail      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

#---
# Excerpted from "Advanced Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_arr for more book information.
#---

class Photo < ActiveRecord::Base
  belongs_to :water_point
  
  has_attachment :content_type => :image, 
                 :storage      => :file_system, 
                 :max_size     => 2.megabytes,
                 :resize_to    => '640x480>',
                 :thumbnails   => { 
                   :large =>  '96x96>',
                   :medium => '64x64>',
                   :small =>  '48x48>' 
                 }

  validates_as_attachment
  require 'exifr'
  require 'flt'
  include Flt
  
  def getGPS
    logger.info("getGPS begin")
  # EXIFR::JPEG.new('public/images/foto.jpg').gps_latitude
  # DecNum(latratarray[0] + latratarray[1]/60 + latratarray[2]/3600).to_f
    return nil if self.temp_data.blank?
    return nil unless ((self.content_type == 'image/jpeg') || (self.content_type == 'image/jpg'))
    metadata = EXIFR::JPEG.new(StringIO.new(self.temp_data))
    if metadata.blank? || metadata.gps_latitude.blank? || metadata.gps_longitude.blank?
      nil
    else
      #logger.info("__________EXIF metadata: #{metadata}")
      #logger.info("raw gps coords from exif data: #{metadata.gps_latitude.to_s}, #{metadata.gps_longitude.to_s}")
      latratarray = metadata.gps_latitude
      lonratarray = metadata.gps_longitude
      latdec = DecNum(latratarray[0] + latratarray[1]/60 + latratarray[2]/3600).to_f
      londec = DecNum(lonratarray[0] + lonratarray[1]/60 + lonratarray[2]/3600).to_f
      #logger.info("parsed gps coords from exif:,#{latdec},#{londec}")
      [latdec, londec]
    end
  end
  
end


=begin

  validate :attachment_valid?  

  def attachment_valid?
    unless self.filename
      errors.add_to_base("No cover image file was selected") 
    end
    
    content_type = attachment_options[:content_type]
    unless content_type.nil? || content_type.include?(self.content_type)
      errors.add_to_base("Cover image content type must an image")
    end
    
    size = attachment_options[:size]
    unless size.nil? || size.include?(self.size)
      errors.add_to_base("Cover image must be 500-KB or less")
    end
  end

=end
