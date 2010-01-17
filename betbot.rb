require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

#change the following to http://www.winthetrophy.com/apiv1 when available
wtt_url   = 'http://localhost:3000/apiv1'
api_key   = 'b1d8338ee7ad9c257e4b91fbf23777b1d0979788'
bet_weeks = "#{wtt_url}/bet_weeks.json?api_key=#{api_key}"
events    = "#{wtt_url}/events.json?api_key=#{api_key}"

get '/' do
  #Get # of chips for the current betweek.
  #If none, you're done until the next time you check.
  @bet_weeks = JSON.parse(RestClient.get(bet_weeks))
  @chips = @bet_weeks[0]['chips_available']

  unless @chips == 0
    #Get all the games in the next 24 hours.
    @events = JSON.parse(RestClient.get(events))
#    #For each game, determine the highest payout; record the points for it.
#    @events.each do |game|
#      over_price  = game['overunder']['over_price']
#      under_price = game['overunder']['under_price']
#      home_price  = game['moneyline']['home_line']
#      away_price  = game['moneyline']['away_line']
#      #we won't deal with spreads for now...

#      @over_payout  = over_price  < 0 ? -100/over_price  : over_price /100
#      @under_payout = under_price < 0 ? -100/under_price : under_price/100
#      @home_payout  = over_price  < 0 ? -100/home_price  : home_price /100
#      @away_payout  = over_price  < 0 ? -100/away_price  : away_price /100

#    end
#    #Sum all the points and divide by the available chips = chips_per_point.
#    #For each game, bet points*chips_per_point on the highest payout.
  end

  haml :index
end

get '/game/:event_id/bet_line_type/:type/pick/:pick/wager_amount/:wager/' do
  #also need to account for bet_week... take a look at the latest
  #bet controller after pulling it.

  @event_id = params[:event_id]
  #type can be overunder, moneyline, or spread
  @type     = params[:type]
  #team or over/under 
  @pick     = params[:pick] 
  @wager    = params[:wager]

  bet_url = "#{wtt_url}/bets.json"

  RestClient.post(bet_url, :event_id => @event_id, :bet_line_type => @type, :pick => @pick,
                           :wager => @wager, :api_key => api_key )

  haml :bet
end
