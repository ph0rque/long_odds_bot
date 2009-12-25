require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'

wtt_url = 'http://localhost:3000'
api_key = '2bfd15f70be65116b6c0f29a701a97a0632adeb5'

#Get # of chips for the current betweek; if zero, you're done until the next time you check.
get '/' do
  t3st = RestClient.get "#{wtt_url}/apiv1/leagues.json?api_key=#{api_key}"
  "#{JSON.parse(t3st)}"
end

#Get all the games in the next 24 hours.
#For each game, determine the highest payout; record the points for it.
#Add all the points together and divide by the available chips = chips_per_point.
#For each game, bet points*chips_per_point on the highest payout.
#Check again in an hour to see if you have won anything.
