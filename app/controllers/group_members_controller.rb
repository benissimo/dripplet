class GroupMembersController < ApplicationController

  before_filter :login_required, :except => [ :index, :show  ]

  def toggle

    #Check whether already subscribed
    params[:group_member][:user_id] = @current_user.id
    @member = GroupMember.find_by_user_id_and_group_id(@current_user.id, params[:group_member][:group_id])
    if @member && (params['subscribe'] == "false")
      #already subscribed. request is to unsubscribe. --> delete
      save_attempt = @member.destroy
    elsif params['subscribe'] == "true" && @member.blank?
      #request is to subscribe. no record found. --> insert
      @member = GroupMember.new(params[:group_member])
      save_attempt = @member.save
    else
      ## all other cases, ignore. redundant or incoherent requests..
      save_attempt = nil
    end



    #debugger
    respond_to do |format|
      if save_attempt
        format.any(:html,:iphone) { redirect_to('/') } #where to send?
        format.xml  { head :ok }
        format.js {
          #get list of members. rjs template needs them.
          @group = Group.find(params[:group_member][:group_id])
        }#{ head :ok }
      else
        format.any(:html,:iphone) { redirect_to('/') } # error msg?
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
        format.js if request.xhr? { head :unprocessable_entity }
      end
    end

  end
end
