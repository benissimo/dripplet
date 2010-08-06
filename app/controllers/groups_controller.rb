class GroupsController < ApplicationController

  layout :choose_layout
  
  before_filter :login_required, :except => [ :index, :show  ]
  before_filter :admin_required, :only => [ :destroy ]
  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.all
    @bc_title = t('bc.Groups')
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    @bc_title = t('bc.Group')
    @page_ancestors = [{:name=>t('bc.Groups'), :url=>groups_path}]
    @subscribed = current_user && GroupMember.find_by_user_id_and_group_id(@current_user.id, @group.id)
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
  end



  # POST /groups
  # POST /groups.xml
  def create
    params[:group][:user_id]=@current_user.id
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        @groupmember = GroupMember.new(:user_id => @current_user.id, :group_id => @group.id)
        @groupmember.save
        flash[:notice] = t('flash.notice.group') #'Group was successfully created.'
        format.any(:html,:iphone) { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.any(:html,:iphone) { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end



  
  def message
    @group = Group.find(params[:id])
    # send message to all members.
    @message_sent = false
    if @group && params[:message]
      if @group.group_members.blank?
        #nothing to do
      else
        #debugger
        @group.group_members.each do |member|
          #message, group, member, sender
          GroupMailer.deliver_message_to_group(params[:message],@group,member,@current_user)
          @message_sent = true
        end
      end
    end
    respond_to do |format|
      format.any(:html,:iphone) { redirect_to(groups_url) }
      format.js #groups/message.rjs.js
    end
  end
  
  

  ##############The following methods are currently NOT USED. moved them to private so
  ##############that they cannot be accessed by accident. Once final page flow is confirmed,
  ##############these methods can be removed completely.
  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.any(:html,:iphone) { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end


  private

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = t('flash.notice.group_update') # 'Group was successfully updated.'
        format.any(:html,:iphone) { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.any(:html,:iphone) { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end    
  
  
  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end
  
end
