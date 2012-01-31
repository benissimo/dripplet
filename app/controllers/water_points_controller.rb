class WaterPointsController < ApplicationController

  layout :choose_layout

  before_filter :login_required, :except => [ :index, :show,  ]
  before_filter :admin_required, :only => [ :destroy ]
  after_filter :log_visit, :only => [:show]


  # GET /water_points
  # GET /water_points.xml
  def index

=begin
list of water points, paginated.
  filter by up_score (default), commented, recent.

up_score, commented: pagination only while num is greater than zero
--------
But also, reuse this for the JSON calls used to populate homepage map.

“all”, “most verified”, “most visited”, “most commented”
“most verified” = 100 water points with highest score, minimum score = +1
score based only on votes “yes”. keep track of votes “no” but use that only for display on	 waterpoint detail page.
“most visited” = 100 water points with highest visit number, minimum score = 1
“most commented” = 100 water points with highest comment number, minimum = 1

=end

  if params[:sort].blank?
    if request.xhr?
      # Default for ajax request is to load all markers
      params[:sort] = :all
    else
      # Default for water_points home is to sort by date, no longer by up_score
      params[:sort] = :date
    end
  end
  @sort = params[:sort].to_sym

  conditions = case @sort
  when :comments
    if request.format.to_sym == :json
      {:order=>"comments_count DESC, created_at DESC", :conditions=>"comments_count > 0"}
    else
      {:order=>"comments_count DESC, created_at DESC"}
    end
  when :visits
    if request.format.to_sym == :json
      {:order=>"visits DESC, created_at DESC", :conditions=>"visits > 0"}
    else
      {:order=>"visits DESC, created_at DESC"}
    end
  when :score
    if request.format.to_sym == :json
      {:order=>"up_score DESC, created_at DESC", :conditions=>"up_score > 0"}
    else
      {:order=>"up_score DESC, created_at DESC"}
    end
  when :date
    {:order=>"created_at DESC"}
  when :all
    #no sorting, just grab them all from DB as quickly as possible
    {}
  else
    #unrecognized sort case.
    redirect_to('/') && return
  end
  if request.format.to_sym == :json
    if params[:bounds]
      sw,ne = params[:bounds].split('x')
      b = Geokit::Bounds.normalize(sw,ne)
      conditions[:bounds] = b
    end
    @water_points = WaterPoint.visible.all(conditions)

    # limit based on location?

  else
    #avoid doing individual select for each result...
    conditions[:include] = :photo
    conditions[:page] = params[:page] || 1
    conditions[:per_page] = 10
    @water_points = WaterPoint.visible.paginate(conditions)
  end
  @conditions = conditions
  @request = request

    respond_to do |format|
      format.any(:html,:iphone) # index.haml
      format.xml  { render :xml => @water_points }
      format.json { render :json => @water_points.to_json(:only=>[:id, :title, :note, :lat, :lng]) }
    end
  end

  # GET /water_points/1
  # GET /water_points/1.xml
  def show
    @water_point = WaterPoint.visible.find(params[:id]) rescue (redirect_to water_points_path; return)
    @comments = @water_point.comments.visible
    @current_vote = current_user && Vote.find_by_user_id_and_water_point_id(@current_user.id, @water_point.id)
    @subscribed = current_user && Follower.find_by_user_id_and_water_point_id(@current_user.id, @water_point.id)

    make_map('detail')

    @page_ancestors = [{:name=>'Dripplets', :url=> water_points_path}]
    @bc_title = 'Dripplet'

    respond_to(:html,:iphone)

  end

  # GET /water_points/new
  # GET /water_points/new.xml
  def new
    @water_point = WaterPoint.new

    respond_to(:html,:iphone)

  end

  # GET /water_points/1/edit
  def edit
    if nil
      #only allow edit of unconfirmed water_point. only by user who posted it.
      @water_point = WaterPoint.find_by_id_and_user_id_and_confirmed(params[:id], @current_user.id, false)
    else
      @water_point = WaterPoint.find_by_id_and_user_id(params[:id], @current_user.id)
    end
    redirect_to(:action => "index") unless @water_point #bad request...
    make_map('confirm')
    @bc_title = t('bc.EditWaterPoint')
    respond_to(:html,:iphone)
  end

  # POST /water_points
  # POST /water_points.xml
  def create
    params[:water_point][:user_id] = @current_user.id

      # If GPS coords found, save as confirmed and skip confirmation page?
      if params[:photo_file] && !params[:photo_file].blank?
        @photo = Photo.new(:uploaded_data => params[:photo_file])
        @coords = @photo.getGPS
        # If photo GPS coords found, use those.
        if @coords && @coords[0] && @coords[1]
          params[:water_point][:lat] = @coords[0]
          params[:water_point][:lng] = @coords[1]
        end
        @water_point = WaterPoint.new(params[:water_point])
        @service = WaterPointService.new(@water_point, @photo)
        save_attempt = @service.save
      else
        @water_point = WaterPoint.new(params[:water_point])
        save_attempt = @water_point.save
      end

    respond_to do |format|
      if save_attempt
        if params[:notify]
          @water_point.reload
          @follower = Follower.new({:user_id => @water_point.posted_by.id,
                                    :water_point_id => @water_point.id})
          @follower.save
        end
        flash[:prompt] = t('flash.prompt.wp') #'WaterPoint loaded. Please confirm location to publish.'
        #format.html { redirect_to(@water_point) }
        format.any(:html,:iphone) { redirect_to(:action=>:edit,:id=>@water_point.id)  }
        format.xml  { render :xml => @water_point, :status => :created, :location => @water_point }
      else
        format.any(:html,:iphone) { render :action => "new" }
        format.xml  { render :xml => @water_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /water_points/1
  # PUT /water_points/1.xml
  def update

    @water_point = WaterPoint.find_by_id_and_user_id(params[:id], @current_user.id)

####Begin: adjust for an update
    #@user = current_user
    @photo = @water_point.photo #default is whatever photo (if any) already exists

    if params[:photo_file] && !params[:photo_file].blank?
      @photo = Photo.new(:uploaded_data => params[:photo_file])
      @coords = @photo.getGPS
      # If photo GPS coords found, use those?
      if @coords && @coords[0] && @coords[1]
        coords_found = true
        params[:water_point][:lat] = @coords[0]
        params[:water_point][:lng] = @coords[1]
      end
      @service = WaterPointService.new(@water_point, @photo)
      save_attempt = @service.update_attributes(params[:water_point], params[:photo_file])
    else
      save_attempt = @water_point.update_attributes(params[:water_point])
    end
#####End
    respond_to do |format|
      if save_attempt
        if coords_found
          flash[:prompt] = t('flash.prompt.wp') #'WaterPoint loaded. Please confirm location to publish.'
          #format.html { redirect_to(@water_point) }
          format.any(:html,:iphone) { redirect_to(:action=>:edit,:id=>@water_point.id)  }
          format.xml  { render :xml => @water_point, :status => :created, :location => @water_point }
        else
          flash[:notice] = t('flash.notice.wp') #'WaterPoint published.'
          format.any(:html,:iphone) { redirect_to(@water_point) }
          format.xml  { head :ok }
        end
      else
        format.any(:html,:iphone) { render :action => "edit" }
        format.xml  { render :xml => @water_point.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /water_points/1
  # DELETE /water_points/1.xml
  def destroy
    @water_point = WaterPoint.find_by_id(params[:id])
    @water_point.destroy

    respond_to do |format|
      format.any(:html,:iphone) { redirect_to(water_points_url) }
      format.xml  { head :ok }
    end
  end

  # Hide waterpoint from view
  def disable
    @water_point = WaterPoint.find_by_id_and_user_id(params[:id], @current_user.id)
    @water_point.delete!
    respond_to do |format|
      format.any(:html,:iphone) { redirect_to water_points_path }
      format.xml { head :ok }
    end
  end

  protected

  def log_visit
    #debugger
    if session[:user_agent_and_session_ok]
      unless session[:visits]
        session[:visits] = {'start'=>1}
      end
      unless (session[:visits] && session[:visits]["#{params[:id]}"])
        @wp = WaterPoint.visible.find(params[:id]) rescue return #can't find it? no problem...
        unless @wp.blank?
          @wp.visits = @wp.visits + 1
          @wp.save(false)
          session[:visits]["#{@wp.id}"] = 1
        end
      end
    end
  end



end
