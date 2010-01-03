require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'

#change the following to http://www.winthetrophy.com/apiv1 when available
wtt_url = 'http://localhost:3000/apiv1'
api_key = '2bfd15f70be65116b6c0f29a701a97a0632adeb5'

#Get # of chips for the current betweek.
#If none, you're done until the next time you check.
get '/' do
  bet_weeks = RestClient.get "#{wtt_url}/bet_weeks.json?api_key=#{api_key}"
  bet_weeks = JSON.parse(bet_weeks)  
  chips = bet_weeks[0]['bet_week']['chips']

  "You have #{chips} chips.<br /><br />"
  if chips == 0
    "Try again later!"
  else
    #Do stuff here...
  end
end

#Get all the games in the next 24 hours.
#For each game, determine the highest payout; record the points for it.
#Sum all the points and divide by the available chips = chips_per_point.
#For each game, bet points*chips_per_point on the highest payout.
#Check again in an hour to see if you have won anything.
