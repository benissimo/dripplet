class UsersController < ApplicationController
  layout :choose_layout

  # Protect these actions behind an admin login
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  
  before_filter :login_required, :only => [ :edit, :update ]  


  
  # render new.rhtml
  def new
    @user = User.new
    respond_to(:html,:iphone)
  end

  def forgot
    @user = User.new
    respond_to(:html,:iphone)
  end
  
  def forgot_check
    @user = User.find_by_login_and_email(params[:login],params[:email])
    if @user
      flash[:notice] = t('flash.notice.forgot') #"Please check your email. We have sent you a new password."
      @user.send_new_password
      redirect_back_or_default('/')      
    else
      flash.now[:error] = t('flash.error.forgot') #"We couldn't find any account matching that data. Please try again."
      @login       = params[:login]
      @email       = params[:email]
      render :action => 'forgot'
    end
  end
 
  def create
    logout_keeping_session!
    params[:user][:locale] ||= @locale
    @user = User.new(params[:user])
    @user.last_ip = @user.first_ip = request.env['REMOTE_ADDR']
    if params[:terms] # should never be blank. this is just insurance in case JS check fails.
      @user.register! if @user && @user.valid?
      success = @user && @user.valid?
      if success && @user.errors.empty?
        redirect_back_or_default(root_path)
        flash[:notice] = t('flash.notice.user') #"Thanks for signing up!  We're sending you an email with your activation code."
      else
        flash.now[:error]  = t('flash.error.user') #"Please correct the errors below."
        render :action => 'new'
      end
    else
      # Ugly, so much for DRY code...
      flash.now[:error] = t('flash.error.terms') #"Please accept the terms of service."
      @user.errors.add t('terms'), t('required') # 'Terms of service', "required"
      render :action => 'new'
    #@user.errors.push "You must accept the terms of service"
    end
    
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = t('flash.notice.activated') #"Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = t('flash.error.activation.blank') #"The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = t('flash.error.activation.invalid') #"We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    # sets user state to "deleted". does not modify associated objects (wp, group_members, etc.)
    @user.delete!
    redirect_to users_path
  end

  def purge
    # deletes user from DB, removes all associated objects.
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

  ##################### BEGIN methods copied over from previously generated user model



  # GET /users
  # GET /users.xml
  def index
    # search only for users with active state.
    params[:sort] ||= :date #default
    @sort = params[:sort].to_sym
    conditions = case @sort
    when :alpha
      {:order=>"login"}
    when :posts
      {:order=>"water_points_count DESC, created_at DESC"}
    when :score
      {:order=>"up_scores DESC, created_at DESC"} #number of "up" votes received for all water points posted
    when :date
      {:order=>"created_at DESC"} #most recent
    end
    conditions[:include] = :avatar   
    conditions[:page] = params[:page] || 1
    conditions[:per_page] = 6
    @conditions = conditions
    @users = User.normal.active.paginate(conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.iphone
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    if @user.state != 'active' or @user.login == 'admin'
      return redirect_to users_path
    end
    
    @page_ancestors = [{:name=>'Community', :url=> users_path}]
    @bc_title = 'User Profile'
    
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user #User.find(params[:id])
    if !(@user.id == params[:id].to_i)
      redirect_to :id=>@user.id
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user
    @avatar = @user.avatar
    
    @service = UserService.new(@user, @avatar)
    
    params[:user][:last_ip] = request.env['REMOTE_ADDR']
    respond_to do |format|
      if @service.update_attributes(params[:user], params[:avatar_file]) ###@user.update_attributes(params[:user])
        flash[:notice] = t('flash.notice.user_update') # 'User was successfully updated.'
        format.any(:html,:iphone) { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.any(:iphone,:html) { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  ##################### END methods copied over from previously generated user mode
  
protected
  def find_user
    @user = User.find(params[:id])
  end
  
  def admin_required
    unless (logged_in? && @current_user && @current_user.login == 'admin')
      flash[:error]  = t('flash.error.not_allowed') #"Action not allowed."
      access_denied
    end
  end
end
