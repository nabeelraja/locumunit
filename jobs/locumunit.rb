require 'google_drive'
require 'roo'

#set up some info
sheetkey="1_gqwTaCkiNi0O0jFEyIJfcB2W4FhZ5oFUlpHjVUc8sc"
sheetfull="https://docs.google.com/spreadsheet/ccc?key=" + sheetkey   #use this to see the actual sheet
sheetresults = "#gid=967078748"                 #append this to the URL for the sheet this program will use (pubmed_result)
results = sheetfull + sheetresults      #hey look I did it for you...

#puts "Please enter your Gmail address"
#GOOGLE_MAIL = gets
#puts "Please enter your password"
#GOOGLE_PASSWORD = gets

GOOGLE_MAIL = 'info@asnglobal.in'
GOOGLE_PASSWORD = 'asngc12398'

SCHEDULER.every '2m', :first_in => 0 do |job|
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately

	# This passes the login credentials to Roo without requiring every user change system environment variables
	s = Roo::Google.new(sheetkey, user: GOOGLE_MAIL, password: GOOGLE_PASSWORD) #Loading spreadsheet :-)
	s.default_sheet = 'Management MI'

	send_event('clinic_details', { cliniclocation:s.cell('C',2), clinicdate:s.cell('C',3) })
	send_event('target', { value:s.cell('C',10), max:s.cell('C',4) })
	send_event('cc1', { value:s.cell('C',8) })
	send_event('cc2', { value:s.cell('C',9) })
	send_event('total_leads', { value:s.cell('C',10) })
	send_event('taxis_booked', { value:s.cell('F',9) })
	send_event('home_visits', { value:s.cell('I',9) })
	send_event('letters_dispatched', { value:s.cell('C',15) })
	
	#top_agents = Hash.new
	
	#for i in 1..10
	#	top_agents[s.cell('D',i,'Pivot Table 12')] = { label: s.cell('D',i,'Pivot Table 12'), value: s.cell('E',i,'Pivot Table 12').to_i }
   	#	#puts s.cell('D',i,'Pivot Table 12')
	#end
	#send_event('top_agents', { items: top_agents.values })
	#top_agents.each_value {|value| puts value}
	
end