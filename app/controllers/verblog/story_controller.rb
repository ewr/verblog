module Verblog
  class StoryController < ApplicationController
  
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
        
      @story.timestamp = Time.now()
      #@story.author = @current_user
    
      if @story.save
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
    
    # Return two structures: the collection of authors currently on the story and 
    # the collection of authors eligible to be added
    def authors
      # get the authors on the story
      @authors = @story.authors.as_json :methods => :name
      
      u = Verblog::Config.user_model.constantize
      
      @all = u.respond_to?(:is_author) ? u.is_author.all : u.all
      
      render :json => {
        :authors => @story.authors.as_json( :only => [:id, :user_id, :is_primary], :methods => [:name] ),
        :all => @all.as_json( :only => [:id,:name] )
      }
    end
    
    #----------
    
    def preview
      
    end
  
    #----------
  
    def scheme
      @story.story_asset_scheme = params[:story][:story_asset_scheme]
      @story.save
    
      redirect_to @story.link_path
    end
  
    #----------
  
    def preview
    
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
