#Header
=begin
Contact Information
-------------------
Author: Nabeel Raja
E-mail: <nabeel.raja@outlook.com>
=end

# Constants
SERVICE_ACCOUNT_EMAIL_ADDRESS = '883449734681-ksqn5mmeijhcvq79elsmc318oae6ihun@developer.gserviceaccount.com'
PATH_TO_KEY_FILE              = 'client.p12'
SECRET                        = 'notasecret'
GOOGLE_SHEET_KEY			  = '1_gqwTaCkiNi0O0jFEyIJfcB2W4FhZ5oFUlpHjVUc8sc'

require "google/api_client"
require 'google_drive'

# set up a client instance
client = Google::APIClient.new(
  :application_name => 'Example Ruby application',
  :application_version => '1.0'
  )
  
# initialize the client instance to get the service
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience             => 'https://accounts.google.com/o/oauth2/token',
  :scope                => 'https://www.googleapis.com/auth/drive',
  :issuer               => SERVICE_ACCOUNT_EMAIL_ADDRESS,
  :signing_key          => Google::APIClient::PKCS12.load_key(PATH_TO_KEY_FILE, SECRET)
  ).tap { |auth| auth.fetch_access_token! }

# get the access token
access_token = client.authorization.access_token

# Creates a session.
session = GoogleDrive.login_with_oauth(access_token)

# get the manangemnt mi sheet
mws = session.spreadsheet_by_key(GOOGLE_SHEET_KEY).worksheet_by_title('Management MI')

# get the agents mi sheet
aws = session.spreadsheet_by_key(GOOGLE_SHEET_KEY).worksheet_by_title('Agents MI')

# scheduler to fetch the data from the google spreadsheet
SCHEDULER.every '2m', :first_in => 0 do |job|
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
	
	# Reloads the worksheets to get the changes/updated values
	mws.reload()
	aws.reload()
	
	# send the event to the dashboard template to populate the dashboard values
	send_event('clinic_details', { cliniclocation:mws['C2'], clinicdate:mws['C3'] })
	send_event('target', { value:mws['C11'], max:mws['C4'], title:"Clinic Target #{mws['C4'].to_i}" })
	send_event('cc1', { value:mws['C8'] })
	send_event('cc2', { value:mws['C9'] })
	send_event('cc3', { value:mws['C10'] })
	send_event('total_leads', { value:mws['C11'] })
	send_event('taxis_booked', { value:mws['F11'] })
	send_event('letters_dispatched', { value:mws['C18'] })
	
	# populate the agent stats widget on the dashboard
	agent_stats = Hash.new
	
	for i in 2..aws.num_rows().to_i - 1
		agent_stats[aws.cell[i,1]] = { label: aws.cell[i,1], value: (aws.cell[i,2]).to_i }
	end
	
	send_event('agent_stats', { items: agent_stats.values })
	
	
end