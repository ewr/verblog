module Verblog
  class ArchivesController < ApplicationController
  
    def index
    	@first = Story.find(:all,:order => "timestamp asc", :limit => 1)[0]
  		@count = Story.count()

  		dates = Story.find_by_sql("
  			select 
  				DATE_FORMAT(timestamp,'%Y/%m') as date,
  				count(*) as count
  			from 
  				#{Story.table_name} 
  			where 
  				status = 5 
  			group by 
  				date 
  			order by date desc
  		")

  		@archives = []

  		lyear = 0
  		dates.each { |d|
  			ymon = /(\d{4})\/(\d\d)/.match d.date

  			if ymon[1] != lyear 
  				@archives << []
  				lyear = ymon[1]
  			end

  			@archives[-1] << { :year => ymon[1], :month => ymon[2] , :count => d.count }

  		}  
    end
  
    #----------
  
    def month
      # parse the date
  		date = [ 
  		  params[:year].to_i || Date.today.year,
  		  params[:month].to_i || Date.today.month
  		]

  		@date = Date.new(*date)
		
      @stories = Story.published.where(
        :timestamp => @date..(@date >> 1)
  		).order("timestamp asc").page(params[:page] || 1).per(12)
    end
  
    #----------
  end
end