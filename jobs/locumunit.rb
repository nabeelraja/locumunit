require 'google_drive'
require 'roo'

#set up some info
sheetkey="1Xs0p8OgbDxXQus5-KwPunNpNc18hT6XVz-IebbFp23c"
sheetfull="https://docs.google.com/spreadsheet/ccc?key=" + sheetkey   #use this to see the actual sheet
sheetresults = "#gid=967078748"                 #append this to the URL for the sheet this program will use (pubmed_result)
results = sheetfull + sheetresults      #hey look I did it for you...

#puts "Please enter your Gmail address"
#GOOGLE_MAIL = gets
#puts "Please enter your password"
#GOOGLE_PASSWORD = gets

GOOGLE_MAIL = 'info@asnglobal.in'
GOOGLE_PASSWORD = 'asngc12398'

SCHEDULER.every '10m', :first_in => 0 do |job|
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately

	# This passes the login credentials to Roo without requiring every user change system environment variables
	s = Roo::Google.new(sheetkey, user: GOOGLE_MAIL, password: GOOGLE_PASSWORD) #Loading spreadsheet :-)
	s.default_sheet = 'Management MI'

	send_event('target', { value:s.cell('C',6) })
	send_event('cc1', { value:s.cell('C',4) })
	send_event('cc2', { value:s.cell('C',5) })
	send_event('total_leads', { value:s.cell('C',6) })
	
	top_agents = Hash.new
	
	for i in 1..10
		top_agents[s.cell('D',i,'Pivot Table 12')] = { label: s.cell('D',i,'Pivot Table 12'), value: s.cell('E',i,'Pivot Table 12').to_i }
   		#puts s.cell('D',i,'Pivot Table 12')
	end
	send_event('top_agents', { items: top_agents.values })
	#top_agents.each_value {|value| puts value}
end