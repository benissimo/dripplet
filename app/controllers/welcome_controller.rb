class WelcomeController < ApplicationController

  layout :choose_layout

  # TODO: rename controller. welcome doesn't really fit...
  def index

      @count = WaterPoint.visible.all.count

      #get last published water point
      #@water_point = WaterPoint.visible.last

      # new layout: no map on hp
      #make_map('detail','satellite')
      @bc_title = 'Home'
      respond_to(:html,:iphone)
  end

  def map
    @water_point = WaterPoint.visible.with_photo.last
    make_map('search', nil, true)

    #centered on latest wp with photo, using special detail view.


    respond_to(:html,:iphone)
  end

  def links
    respond_to(:html,:iphone)
  end

  def terms
    respond_to(:html,:iphone)
  end

  def story
    respond_to(:html,:iphone)
  end

  def credits
    respond_to(:html,:iphone)
  end

  def netiquette
    respond_to(:html,:iphone)
  end
end
