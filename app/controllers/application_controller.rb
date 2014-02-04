# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  include AuthenticatedSystem

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :confirm_password

  before_filter :host_check if ENV["RAILS_ENV"] == 'production'
  before_filter :session_user_agent_check
  before_filter :set_locale
  #before_filter :adjust_format_for_iphone

  #move this to different class?
  def make_map(type='detail',satellite=false,world=false)
        # Create a new map object, also defining the div ("map")
        # where the map will be rendered in the view
        @map_type = type.to_sym
        case @map_type
        when :detail
          @map_conf = {
            :width => 690,
            :height => 400}
          @side_type = :map_search
        when :search
          @map_conf = {
            :width => 690,
            :height => 400}
          @side_type = :map_search
        when :confirm
          @map_conf = {
            :width => 690,
            :height => 400}
          @side_type = :map_search_confirm
        else
          raise 'Unrecognized map type'
        end

        if request.format == :iphone
          @map_conf = {
            :width => 320,
            :height => 200
          }
        end


        @map = {};
        # ym4r/gm plugin api: http://ym4r.rubyforge.org/ym4r_gm-doc/

        if satellite
          @map['zoom'] = 4
        else
          @map['zoom'] = 18

        end
        @map['zoom'] = 11 if world


        if !@water_point.blank? && !@water_point.lat.blank? && !@water_point.lng.blank?
          @map['lat'] = @water_point.lat
          @map['lng'] = @water_point.lng
          @map['zoom'] = 18

          if (@map_type == :detail) or (@map_type == :search)
            #  @map.global_init(@map.enable_google_bar())
            #note = @water_point.note.to_s.mb_chars.length > 160 ? @water_point.note.to_s.mb_chars[0,160].to_s+'...</a>' : @water_point.note;
            note = @water_point.note

            if @map_type == :detail
              @map['marker_info'] = "<b>#{@water_point.title}</b><br/>#{note}"
            else
              #special case
              photo = @template.photo_for(@water_point, :large)
              @map['marker_info'] = "<div style='overflow:hidden'><b><a href='/#{@locale}/water_points/#{@water_point.id}'>#{@water_point.title}</a></b><br/>#{photo}<br/>"+t('thanks_to')+" <a href='/#{@locale}/users/#{@water_point.posted_by.id}'>#{@water_point.posted_by.login}</a></div>"
            end


            @map['marker_title'] = @water_point.title
            ### Bug in GM library? The following line should work, but instead generates an error:
            #@map.icon_global_init(GIcon.new(:image => "/images/markers/lightblue.png"), "detail_icon")
            ### instead need to specify these other attribs as well, even though gmaps api doesn't require them!



            #@map.icon_global_init(GIcon.new(:image => "/images/markers/lightblue.png", :icon_size => GSize.new(16,16),:icon_anchor => GPoint.new(8.0,8.0),:info_window_anchor => GPoint.new(8.0,8.0),:shadow => "/images/markers/shadow.png", :shadowSize => GSize.new(25.0,16.0)),"detail_icon")
            #detail_icon = Variable.new("detail_icon")
            #marker = GMarker.new([@water_point.lat,@water_point.lng],
             #                 :title=> @water_point.title,
              #                :icon=> detail_icon
              #                )
            #@map.declare_init(marker, "marker") #THANK YOU to this post: http://blog.odeley.com/?p=40
            #@map.overlay_init(marker)

            ###@map.record_init 'window.alert("foo "+detail_icon.image+" typeof "+typeof detail_icon+" mic "+marker.getIcon().image);'

            # bindInfoWindowHtml() offers max_width option. GMarker constructor doesn't.
            #@map.record_init marker.bind_info_window_html(info, :max_width => 300)
            #@map.record_init marker.open_info_window_html(info, :max_width => 300) #needed here too...
          end
        else
          # Default center location. no auto open marker.
          #@map.center_zoom_init([41.898,12.518],zoom)
          @map['lat'] = 41.898
          @map['lng'] = 12.518
        end


        #mm = GMarkerManager.new(@map)#,:managed_markers => [managed_markers1,managed_markers2,managed_markers3])
        #@map.record_init "window.WH_mgr = new MarkerManager(map);"#,:managed_markers => [managed_markers1,managed_markers2,managed_markers3])

#        @map.declare_init(mm,"mgr")

        @map['skip_id'] = @water_point.blank? ? '' : @water_point.id

        #@map.record_init "WH_LoadMarkerFeed(map,window.WH_mgr,'all'"+skip_id+");"

        # Thank you: http://www.daftlogic.com/sandbox-google-maps-centre-crosshairs.htm
        crosshair_js = <<CROSSHAIR_JS_BLOCK
        //var crosshairsSize=19;
        var crosshairsSize=34;//img is really 68...
        google.maps.Map.prototype.addCrosshairs=function()
        {
        var container=$('map'); //this.getContainer();
        if(this.crosshairs)
        this.removeCrosshairs();

        var crosshairs=document.createElement("img");
        //crosshairs.src='http://www.daftlogic.com/images/crosshairs.gif';
        crosshairs.src='/images/target_pointer.png';
        crosshairs.style.width=crosshairsSize+'px';
        crosshairs.style.height=crosshairsSize+'px';
        crosshairs.style.border='0';
        crosshairs.style.position='relative';
        crosshairs.style.top=((container.clientHeight-crosshairsSize)/2)+'px';
        crosshairs.style.left=((container.clientWidth-crosshairsSize)/2)+"px"; // The map is centered so 0 will do
        crosshairs.style.zIndex='500';
        container.appendChild(crosshairs);
        this.crosshairs=crosshairs;
        return crosshairs;
        };

        map.addCrosshairs();

        //Extra stuff
        google.maps.event.addListener(map,'bounds_changed',function() {
          var center = map.getCenter();
          $('water_point_lat').value = center.lat();
          $('water_point_lng').value = center.lng();
        });

        //move this to server-side...
        //populate w current center val if empty...
        if (!($('water_point_lat').value && $('water_point_lng').value)) {
          var center = map.getCenter();
          $('water_point_lat').value = center.lat();
          $('water_point_lng').value = center.lng();
        }
CROSSHAIR_JS_BLOCK
    @map['crosshair_js'] = crosshair_js
  end


protected
  def set_locale
    if params[:locale].blank?
      redirect_to :locale => 'en'
    end
    @locale = I18n.locale = params[:locale]
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = I18n.translate('previous')
    WillPaginate::ViewHelpers.pagination_options[:next_label] = I18n.translate('next')
  end

  def is_megatron?
    request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end

  def session_user_agent_check
    ##################################################
    #If user agent matches bot pattern
    #or if user not accepting cookies (no session)
    #then session[:user_agent_and_session_ok] will be missing.
    #Use presence of session[:user_agent_and_session_ok] as test whether to do things like
    #incrementing visit counter for water points.
    ##################################################
    logger.info("session check called")
    if is_megatron?
      logger.info("bot.......................")
      #leave session empty. avoid writing to session for bots.
    else
      session[:user_agent_and_session_ok] = 1
    end
  end

  def host_check
    if request.host != 'www.dripplet.com'
      # per google's specs, use 301 redirect in this case...
      redirect_to_full_url('http://www.dripplet.com'+request.path,301) and return
    end
  end


  def admin_required
    unless (logged_in? && @current_user && @current_user.login == 'admin')
      flash[:error]  = t('flash.error.not_allowed') #"Action not allowed."
      access_denied
    end
  end

  def adjust_format_for_iphone
    # iPhone sub-comain request
    # request.format = :iphone if iphone_subdomain?

    # Detect from iPhone user-agent
    # html and js (or whatever gets generated via xhr by iui OK. json no.)
    request.format = :iphone if iphone_user_agent? and (request.format != :json)
  end

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] &&
    request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/] &&
    !request.env["HTTP_USER_AGENT"][/Ipad/]
  end

  def choose_layout
    'main'
  end

  def choose_layout_OLD
    if request.format == 'iphone'
      #debugger
      if ["welcome.index", "water_points.show", "welcome.map", "water_points.new", "water_points.edit",  "sessions.new"].include?("#{controller_name}.#{action_name}")
        # welcome.index because it's the starting point
        # water_points.show and welcome.map because they load map data and getting all the JS to play nice together
        #  without any risk of memory leak etc. would require too much time for now.
        # water_points.new because there's the redirect through login that mucks up iui's logic.
        # likewise for login
        'main'
      else
        'minimal'
      end
    else
      'main'
    end
  end

end
