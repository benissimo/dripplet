module WaterPointsHelper
  def photo_for(water_point, size = :medium)
    if water_point.photo
      photo_image = water_point.photo.public_filename(size)
      link_to image_tag(photo_image, :class=>'photo'), water_point.photo.public_filename, :rel=>'lightbox', :title=>(h water_point.title)
    elsif water_point.photo_url
      link_to image_tag(water_point.photo_url, :class=>'photo',
                                                :width=>Photo.attachment_options[:thumbnails][size].split('x')[0]),
                                                water_point.photo_url, :rel=>'lightbox', :title=>(h water_point.title)
    else
      image_tag("blank-photo-#{size}.png", :class=>'photo')
    end
  end

  def remove_comment(comment)
    remote_function(:url    => url_for(comment),
                    :method => :put,
                    :before => "Element.show('spinner-#{comment.id}')",
                    :complete => "Element.hide('comment-#{comment.id}')",
                    :with => "'comment[enabled]=0'")
  end


end
