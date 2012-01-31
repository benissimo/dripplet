class CommentsController < ApplicationController

  layout :choose_layout

  before_filter :login_required, :except => [ :index, :show,  ]

  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.iphone
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.iphone
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    params[:comment][:user_id] = current_user.id
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.' unless request.xhr?
        #format.html { redirect_to(@comment) }
        format.any(:html,:iphone) { if request.xhr?
                        render :partial => 'shared/comment', :locals => {:comment => @comment}
                      else
                        #remove this?
                        redirect_to(@comment)
                      end
                    }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.js
      else
        format.any(:html,:iphone) { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        format.js { head :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    #@comment = Comment.find(params[:id])
    @comment = current_user.comments.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        # flash[:notice] = 'Comment was successfully updated.'
        format.any(:html,:iphone) { redirect_to(@comment) }
        format.xml  { head :ok }
        format.js { head :ok }
      else
        format.any(:html,:iphone) { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        format.js { head :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.any(:html,:iphone) { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
