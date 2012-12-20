module Verblog
  class StoryController < ::Verblog::ApplicationController
  
    before_filter :verblog_only_author, :except => [:index,:show]
    before_filter :verblog_load_story, :except => [:index,:new,:create]
  
    skip_before_filter :verify_authenticity_token, :only => [:assets]
  
    #----------
  
    def index
    end
  
    #----------
  
    def show
      # if we make it here, it's a valid story and we're authorized
    end
  
    #----------
  
    def new
      @story = Story.new()
    end
  
    #----------
  
    def create
      @story = Story.new(params[:story])
      @story.status = Story::STATUS_DRAFT
      @story.timestamp = Time.now()
    
      if @story.save
        # add the creator as an author
        @story.authors.create :user => current_user
        
        flash[:notice] = "Story saved successfully."
        redirect_to @story.story_link
      else
        flash[:notice] = "Failed to save story: #{@story.errors.full_messages.join(" | ")}"
        render :action => "new"
      end
    end
  
    #----------
  
    def assets
      assets = JSON.parse(params[:assets])
    
      assets.each_with_index do |a,idx|
        puts "a is #{a}"
        if sa = @story.assets[idx]
          sa.update_attributes(
            :asset_id => a['id'],
            :position => idx,
            :caption  => a['caption']        
          )
        else
          @story.assets.create(
            :asset_id => a['id'],
            :position => idx,
            :caption  => a['caption']
          )
        end
      end

      # delete leftover assets
      if @story.assets.length > assets.length
        @story.assets[assets.length..-1].each {|sa| sa.destroy }
      end
    
      render :text => "Assets is #{@story.assets}"
    end
    
    #----------
    
    def status
      status = params[:story][:status].to_i
      
      # support for checking publish rights
      if status == Story::STATUS_LIVE && current_user.respond_to?(:can_publish?) && !current_user.can_publish?
        flash[:notice] = "You do not have rights to publish."
        redirect_to story_path(@story) and return
      end
      
      @story.status = status
      
      if @story.save
        # deliver status message
        # TODO: Implement status message
        
        flash[:notice] = "Successfully set status to #{ Story::STATUS_TEXT[ @story.status ]}."
        redirect_to story_path(@story)
      else
        flash[:notice] = "Error setting status: #{ @story.errors.full_messages.join(" | ") }"
        redirect_to story_path(@story)
      end
    end
    
    #----------
        
    def preview
      # we add title, intro and body into the @story object for preview, but don't save
      @story.attributes = params[:story] if params[:story]
      #render :partial => "body"
      render :formats => [:js]
    end
  
    #----------
  
    def scheme
      @story.story_asset_scheme = params[:story][:story_asset_scheme]
      @story.save
    
      redirect_to @story.link_path
    end
  
    #----------
  
    def edit
    
    end
  
    #----------
  
    def update
      # grab original status
      ostatus = @story.status
    
      @story.attributes = params[:story]
    
      @story.status = params[:story][:status]
    
      if @story.status == Story::STATUS_LIVE && ostatus != Story::STATUS_LIVE
        # setting to publish, update timestamp
        @story.timestamp = Time.now
      end
    
      if @story.save      
        redirect_to @story.story_link
      else
        flash[:notice] = "Error saving story: #{@story.errors.full_messages.join(" | ")}"
        render :action => "edit"
      end
    end
  
    #----------
  
    def destroy
    
    end
  
    #----------
      
  end
end
