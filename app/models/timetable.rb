class Timetable < ActiveRecord::Base
  serialize :courses
  
  def self.make_new_timetable(itu_email, itu_password)
    a = Mechanize.new { |agent|
	  	agent.user_agent_alias = 'Mac Safari'
	  }
	  
	  login_page = a.get('https://mit.itu.dk/scs/auth/auth_form.sml?target=%252Findex.sml')
	  Rails.logger.info("Got login page")
	  
	  form = login_page.forms.first
	  form.auth_login = itu_email
	  form.auth_password = itu_password
	  form.add_field! 'send', 'Submit'
	  form.submit
	  
	  Rails.logger.info("Submitted form")
	  
	  overview = a.get('https://mit.itu.dk/ucs/cb/index.sml?mode=my_courses')
	  Rails.logger.info("Got course overview")
	  
	  all_courses = {}
	  
	  a.page.search("#course a").each do |link|
	    Rails.logger.info("Found a course")
	  	# course name?
	  	course_page = a.click(link)
	  	course_name = course_page.parser.xpath('/html/body/table[1]/tr[5]/td[1]/span/span[2]').inner_html.force_encoding("ISO-8859-1").encode("UTF-8")
	  	courses = course_page.parser.xpath('/html/body/table[2]/tr/td[2]/table[7]/tr[2]/td/table[1]')
	  	
	  	this_course = []
	  	
	  	Rails.logger.info("Found #{courses.count} times")
	  	
	  	courses.xpath('tr').each do |course|
	  		next if course == courses.children[0]
	  		
	  		course_day = translate_courseday(course.children[0].inner_html)
	  		course_interval = course.children[2].inner_html.split("-")
	  		course_start = course_interval[0]
	  		course_end = course_interval[1]
	  		course_type = course.children[4].inner_html.force_encoding("ISO-8859-1").encode("UTF-8")
	  		course_room = course.children[8].inner_html.force_encoding("ISO-8859-1").encode("UTF-8")
	  		
	  		all_courses[course_day] = {} if all_courses[course_day].nil?
	  		all_courses[course_day][course_start] = {
	  			:name => course_name, :room => course_room, :type => course_type
	  		}	
	  		Rails.logger.info("Added course")
	  	end
  	end
  	return all_courses
  	#return Timetable.create(:itu_email => itu_email, :courses => all_courses)
  end
  
  def self.translate_courseday(string)
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
