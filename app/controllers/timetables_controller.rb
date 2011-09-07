class TimetablesController < ApplicationController

  def index
    
  end
  
  def fetch_timetable
    cache = Timetable.find_by_itu_email(params[:itu_email]) 
	  unless cache
	    if params[:itu_password].blank?
	      redirect_to root_url 
	      return
      end
		  all_courses = Timetable.make_new_timetable(params[:itu_email], params[:itu_password])
		  timetable = Timetable.new
		  timetable.itu_email = params[:itu_email]
		  timetable.courses = all_courses
		  Rails.logger.info(all_courses.inspect)
		  timetable.save
  	end
  	
  	redirect_to "/timetable/show/#{params[:itu_email]}"
  end

	def show
	  cache = Timetable.find_by_itu_email(params[:itu_email])
	  
	  if cache
	    @timetable = cache
	    @all_courses = cache.courses
    else  
		  redirect_to root_url
  	end
	end

	def update
	  @timetable = Timetable.find(params[:id])
	  @timetable.destroy if @timetable
	  redirect_to root_url
	end
	
	private
	def translate_courseday(string)
		case string
			when "Monday"
				return "Mandag"
			when "Tuesday"
				return "Tirsdag"
			when "Wednesday"
				return "Onsdag"
			when "Thursday"
				return "Torsdag"
			when "Friday"
				return "Fredag"
		end
		
		return string
	end
end
