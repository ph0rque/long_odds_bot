require 'rubygems'
require 'sinatra'
require 'betbot_config'
require 'betbot_strategy'
require 'haml'

get '/' do
  if STATUS == 'ok'
    bet_on_games
    haml :bets
  else
    haml :borken    
  end
end

# Do I also want '/bet_weeks', '/events', and '/bets', or just use the WTT UI?
