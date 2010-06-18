require 'rubygems'
require 'sinatra'
require 'betbot_config'
require 'betbot_strategy'
require 'haml'
require 'rufus/scheduler'

get '/' do
  if STATUS == 'ok'
    haml :bets
  else
    haml :borken    
  end
end

get '/make-bets-mofo' do
  if params[:api_key] == API_KEY
    bet_on_games
    haml :bets
  else
    haml :hal
end

# Do I also want '/bet_weeks', '/events', and '/bets', or just use the WTT UI?

#Scheduled bets run at 3am UTC
scheduler = Rufus::Scheduler.start_new
scheduler.every '1d', :first_at => '2010/06/19 3:00 UTC' do
  bet_on_games
end
