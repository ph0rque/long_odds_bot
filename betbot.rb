require 'rubygems'
require 'sinatra'
require 'betbot_config'
require 'betbot_strategy'
require 'haml'
require 'rufus/scheduler'

get '/' do
  if STATUS == 'ok'
    @bet_weeks       = JSON.parse(RestClient.get(BET_WEEKS).body)
    @chips           = @bet_weeks[0]['chips']
    @chips_available = @bet_weeks[0]['chips_available']
    @events          = JSON.parse(RestClient.get(EVENTS).body)

    haml :hello
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
end

# Do I also want the '/bets' view, or just use the WTT UI?

#Scheduled bets run at 3am UTC
scheduler = Rufus::Scheduler.start_new
scheduler.every '1d', :first_at => '2010/06/18 21:14 UTC' do
  bet_on_games
end
