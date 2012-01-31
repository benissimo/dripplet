# == Schema Information
# Schema version: 20100613162817
#
# Table name: avatars
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  parent_id    :integer(4)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  thumbnail    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Avatar < ActiveRecord::Base
  belongs_to :user

  has_attachment :content_type => :image,
                 :storage      => :file_system,
                 :max_size     => 2.megabytes,
                 :resize_to    => '384x384',
                 :thumbnails   => {
                   :large =>  '96x96',
                   :medium => '64x64',
                   :small =>  '32x32'
                 }

  validates_as_attachment
end
