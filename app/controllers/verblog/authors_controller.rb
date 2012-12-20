module Verblog
  class AuthorsController < ::Verblog::ApplicationController
    before_filter :verblog_only_author
    before_filter :verblog_load_story
    
    def index
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
    
    def create      
      a = @story.authors.build
      a.user_id = params[:user_id]
      
      if a.user
        if a.save
          render :json => a.as_json(:only => [:id, :user_id, :is_primary], :methods => [:name])
        else
          render :text => a.errors.full_messages.join(" | "), :status => :error
        end
      else
        render :text => "Invalid user ID", :status => :error
      end
    end
    
    #----------
    
    def update
      author = @story.authors.find(params[:id])
      author.is_primary = params[:is_primary]
      #author.name = params[:name]
      
      if author.save
        render :text => "OK", :status => :ok
      else
        render :text => author.errors.full_messages.join(" | "), :status => :error
      end
    end
    
    #----------

    def destroy
      author = @story.authors.find(params[:id])
      
      if author.destroy
        render :text => "OK", :status => :ok
      else
        render :text => author.errors.full_messages.join(" | "), :status => :error
      end
    end
    
  end
end