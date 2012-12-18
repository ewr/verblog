module Verblog
  class Story < ActiveRecord::Base
    cattr_reader :per_page
    @@per_page = 5
  
    #belongs_to :author, :class_name => Verblog::Config.user_model

    has_many :assets, :class_name => "StoryAsset", :order => "position asc", :dependent => :destroy
    has_many :authors, :class_name => "StoryAuthor", :dependent => :destroy

  	attr_protected :timestamp
	
  	validates_presence_of :title
    validate :needs_text_to_publish

  	before_save :update_url_string
    before_save :expire_content_caches

  	CLIPPING_LENGTH = 150
	
  	#----------
	
  	# Status statics
	
  	STATUS_KILLED  = -1
  	STATUS_DRAFT    = 0
  	STATUS_PENDING	= 3
  	STATUS_LIVE 	  = 5

    STATUS_TEXT = {
      Story::STATUS_KILLED    => 'Killed',
      Story::STATUS_DRAFT     => 'Draft',
      Story::STATUS_PENDING   => 'Pending Publication',
      Story::STATUS_LIVE      => 'Published'
    }

  	AUTHOR_OPTIONS = [
  	  [ 'Kill Story',       Story::STATUS_KILLED ],
  		[ 'Save as Draft',    Story::STATUS_DRAFT ],
  		[ 'Publish',          Story::STATUS_LIVE ]
  	]
	
  	#----------
	
  	# Comment States
	
  	COMMENTS_ALL_ALLOWED  = 2
  	COMMENTS_MEMBERS_ONLY = 1
  	COMMENTS_CLOSED       = 0
	
  	COMMENT_OPTIONS = [
      [ 'Disable Comments',   Story::COMMENTS_CLOSED ],
      [ 'User Comments Only', Story::COMMENTS_MEMBERS_ONLY ],
      [ 'Allow All Comments', Story::COMMENTS_ALL_ALLOWED ]
    ]
    
    #----------
	
  	ASSET_SCHEMES = [
  	  ["Wide",""],
  	  ["Slideshow","slideshow"]
  	]

  	#----------

  	def Story.StatusOptions
  	  if @current_user && @current_user.is_author
  	    return AUTHOR_OPTIONS
  	  else
  	    return []
  	  end
  	end

    #----------
  
    scope :published, where(:status => Story::STATUS_LIVE).order("timestamp desc")
  
    #----------
    
    def published?
      self.status == Story::STATUS_LIVE
    end
    
    #----------
  
    # Content Cache Support -- Define object key
    def obj_key
      "story:#{self.id}"
    end

  	#----------

    def can_edit?(user = current_user)
      user && ( user.editor || (user.author && self.users.include?(user)))
    end

    #----------
        
    # Returns a two-dimensional array
    # authors[0] is primary authors
    # authors[1] is secondary authors
    def sorted_authors
      authors = [[],[]]
      
      if self.authors.length == 1
        authors[0] << self.authors[0]
      else
        self.authors.each do |a|
          if a.is_primary
            authors[0] << a
          else
            authors[1] << a
          end
        end
        
        [0,1].each do |i|
          authors[i] = authors[i].sort { |a,b|
            aN = ((a.respond_to?(:user) && a.user) ? a.user.name : a.name).split(" ").reverse.join("")
            bN = ((b.respond_to?(:user) && b.user) ? b.user.name : b.name).split(" ").reverse.join("")
            
            aN <=> bN
          }
        end
      end
      
      return authors
    end
    
    #----------
    
    def author_names
      names = ''
      
      if self.authors.length == 1
        names = (self.authors[0].respond_to?(:user) && self.authors[0].user) ? self.authors[0].user.name : self.authors[0].name
      else
        authors = self.sorted_authors
        
        [0,1].each do |i|
          authors[i] = authors[i].collect { |a| (a.respond_to?(:user) && a.user) ? a.user.name : a.name }
        end
        
        names = Story.join_authors(authors)
      end
      
      return names
    end
    
    #----------
    
    def self.join_authors(authors)
      if !authors
        return nil
      end
      
      names = []
      
      [0,1].each do |i|
        if authors[i].length == 1
          names << authors[i][0]
        elsif authors[i].length > 1
          names << [ authors[i].pop, authors[i].join(", ") ].reverse.join(" and ")
        end
      end
      
      return names.join(" with ")
    end
    
    #----------

    # Generate a link to the story in the form /YYYY/MM/IDID-stringified-title
    def link_path
      mon = self.timestamp.mon

      if mon < 10
        mon = "0" + mon.to_s
      end

      return [
        (Verblog::Config.blog_path||Verblog::Engine.mounted_path),
        self.timestamp.year,
        mon,
        self.id.to_s + '-' + self.url_string
      ].join('/').gsub(/\/+/,"/")
    end
  
    #----------
  
    def story_link
      self.link_path
    end

    #----------

    def remote_story_link
      return Verblog::Config.base_url + self.link_path
    end

  	#----------

  	def self.generate_url_string(title)
  	  s = title.downcase

  	  s = s.gsub(/\s+/,'_')
  	  s = s.gsub(/\W/,'')
  	  s = s.gsub(/['"]/,'')

  	  s = s.gsub(/_/,'-')

  	  # shorten
  	  if ( s.length > 40 ) 
  			sclip = /^(.{40}\w*)\W/.match(s)

  			if ( sclip ) 
  			  s = sclip[1]
  			else 
  				# do nothing
  			end
  		else 
  			# just let it go
  		end

  	  #s = s.gsub(/-/,'_')

  	  return s
  	end

    #----------
  
  	# Accepts four possible flags as input:
  	# * :any -- Returns true as long as comments aren't disabled (default)
  	# * :none -- Returns true if comments are disabled
  	# * :user -- Returns true if logged in users may comment (status is all or members only)
  	# * :all -- Returns true if status is ALL_ALLOWED (non-auth users may comment)
  	def allows_comments?(type = :any)
  	  if type == :all
  	    return self.comments_allowed == Story::COMMENTS_ALL_ALLOWED ? true : false
      elsif type == :user
        return ([Story::COMMENTS_ALL_ALLOWED,Story::COMMENTS_MEMBERS_ONLY].include?(self.comments_allowed)) ? true : false
      elsif type == :none
        return self.comments_allowed == Story::COMMENTS_CLOSED ? true : false      
      else
        return self.comments_allowed != Story::COMMENTS_CLOSED ? true : false
      end
  	end


  	#----------

  	protected
  	def update_url_string
  	  self.url_string = Story.generate_url_string self.title
  	end
    
    def expire_content_caches
      if Rails.cache.is_a?(ActiveSupport::Cache::RedisContentStore)
        Rails.cache.expire_obj(self)
      end
    end

  	#----------

  	def needs_text_to_publish
  	  if self.status == Story::STATUS_LIVE
  	    errors.add_to_base("Can't publish a story without text") unless self.intro?
  	  end
  	end
  end
  
end