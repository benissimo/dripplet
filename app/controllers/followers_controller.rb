class FollowersController < ApplicationController


  before_filter :login_required, :except => [ :index, :show,  ]  

  def toggle
    
    #Check whether already subscribed
    params[:follower][:user_id] = @current_user.id
    @follower = Follower.find_by_user_id_and_water_point_id(@current_user.id, params[:follower][:water_point_id])
    if @follower && (params['subscribe'] == "false")
      #already subscribed. request is to unsubscribe. --> delete
      save_attempt = @follower.destroy
    elsif params['subscribe'] == "true" && @follower.blank?
      #request is to subscribe. no record found. --> insert
      @follower = Follower.new(params[:follower])
      save_attempt = @follower.save
    else
      ## all other cases, ignore. redundant or incoherent requests..
      save_attempt = nil
    end

    #debugger
    respond_to do |format|
      if save_attempt
        format.any(:html,:iphone) { redirect_to('/') } #where to send?
        format.xml  { head :ok }
        format.js { head :ok }    
      else
        format.any(:html,:iphone) { redirect_to('/') } #where to send?
        format.xml  { render :xml => @follower.errors, :status => :unprocessable_entity }
        format.js if request.xhr? { head :unprocessable_entity }      
      end
    end
    
  end

end
