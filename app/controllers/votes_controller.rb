class VotesController < ApplicationController

  layout :choose_layout

  before_filter :login_required, :except => [ :index, :show,  ]

  # GET /votes
  # GET /votes.xml
  def index
    @votes = Vote.all

    respond_to do |format|
      format.html # index.html.erb
      format.iphone
      format.xml  { render :xml => @votes }
    end
  end

  # GET /votes/1
  # GET /votes/1.xml
  def show
    @vote = Vote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml => @vote }
    end
  end

  # GET /votes/new
  # GET /votes/new.xml
  def new
    @vote = Vote.new

    respond_to do |format|
      format.html # new.html.erb
      format.iphone
      format.xml  { render :xml => @vote }
    end
  end


  def toggle
    params[:vote][:user_id] = @current_user.id
    @vote = Vote.find_by_user_id_and_water_point_id(@current_user.id, params[:vote][:water_point_id])
    if @vote
      save_attempt = @vote.update_attributes(params[:vote])
    else
      @vote = Vote.new(params[:vote])
      save_attempt = @vote.save
    end

    # Do lookups to populate rjs partial. NB these are similar to water_points_controller#show They should be refactored.
    @water_point = @vote.water_point
    @current_vote = current_user && Vote.find_by_user_id_and_water_point_id(@current_user.id, @water_point.id)
    @subscribed = current_user && Follower.find_by_user_id_and_water_point_id(@current_user.id, @water_point.id)


    respond_to do |format|
      if save_attempt
        #format.js { head :ok }
        format.any(:html,:iphone) {
          if request.xhr?
            render :partial=>'votes/vote'
          else
            redirect_to(@vote)
          end
          } #where to send?
        format.xml  { head :ok }
      else
        format.js if request.xhr? { head :unprocessable_entity }
        format.any(:html,:iphone) { render :action => "new" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end

  end

  # GET /votes/1/edit
  def edit
    @vote = Vote.find(params[:id])
  end

  # POST /votes
  # POST /votes.xml
  def create
    @vote = Vote.new(params[:vote])

    respond_to do |format|
      if @vote.save
        flash[:notice] = 'Vote was successfully created.'
        format.any(:html,:iphone) { redirect_to(@vote) }
        format.xml  { render :xml => @vote, :status => :created, :location => @vote }
      else
        format.any(:html,:iphone) { render :action => "new" }
        format.iphone { render :action => "new" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /votes/1
  # PUT /votes/1.xml
  def update
    @vote = Vote.find(params[:id])

    respond_to do |format|
      if @vote.update_attributes(params[:vote])
        flash[:notice] = 'Vote was successfully updated.'
        format.any(:html,:iphone) { redirect_to(@vote) }
        format.xml  { head :ok }
      else
        format.any(:html,:iphone) { render :action => "edit" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.xml
  def destroy
    @vote = Vote.find(params[:id])
    @vote.destroy

    respond_to do |format|
      format.any(:html,:iphone) { redirect_to(votes_url) }
      format.xml  { head :ok }
    end
  end
end
