# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def vote_up(water_point)
    vote(water_point,1,'upvote','downvote')
  end
  
  def vote_down(water_point)
    vote(water_point,-1,'downvote','upvote')
  end
  
  def vote(water_point,rating,which_on,which_off)
    remote_function(:url  => "/#{@locale}/votes/toggle",
                    :method => :post,
                    :before => "Element.show('spinner-vote-#{water_point.id}');Element.removeClassName('#{which_off}','on')",
                    :complete => "Element.hide('spinner-vote-#{water_point.id}');Element.addClassName('#{which_on}','on')",
                    :with => "'vote[rating]=#{rating}&amp;vote[water_point_id]=#{water_point.id}'")
  end

  def toggleSubscribe(water_point)
    remote_function(:url  => "/#{@locale}/followers/toggle",
                    :method => :post,
                    :before => "Element.show('spinner-subscribe-#{water_point.id}');",
                    :complete => "Element.hide('spinner-subscribe-#{water_point.id}');",
                    :with => "this.name + '=' + this.checked + '&amp;follower[water_point_id]=#{water_point.id}'")
  end

  def toggleGroupMembership(group)
    remote_function(:url  => "/#{@locale}/group_members/toggle",
                    :method => :post,
                    :before => "Element.show('spinner-subscribe-#{group.id}');",
                    :complete => "Element.hide('spinner-subscribe-#{group.id}');", #{}"$('notice-msg').innerHTML='joined';Element.show('notice-msg');alert('foo');",
                    :with => "$('subscribe').name + '=' + $('subscribe').checked + '&amp;group_member[group_id]=#{group.id}'")
  end

  def deferred(&block)
    @deferred_content ||= ""
    @deferred_content << capture(&block)
  end
  
end
