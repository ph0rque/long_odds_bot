require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

wtt_url   = 'http://www.winthetrophy.com/apiv1'
api_key   = 'e66cdcc1f1fa5f5515ffc8a336bcf397858c8422'
bet_weeks = "#{wtt_url}/bet_weeks.json?api_key=#{api_key}"
events    = "#{wtt_url}/events.json?api_key=#{api_key}"
beturl    = "#{wtt_url}/bets"

get '/' do
  #Get # of chips for the current betweek.
  #If less than ten, you're done until the next time you check.
  @bet_weeks = JSON.parse(RestClient.get(bet_weeks).body)
  @chips = @bet_weeks[0]['chips_available']
  @points = 0

  unless @chips < 10
    #Get all the games in the next 24 hours.
    @events = JSON.parse(RestClient.get(events).body)

    #For each game, determine the max payout; record the points for it.
    @events.each do |game|
      if game['overunder']
        over_price  = game['overunder']['over_price']  || 0
        under_price = game['overunder']['under_price'] || 0
      else over_price = under_price = 0;  end

      if game['moneyline']  
        home_price  = game['moneyline']['home_line']   || 0
        away_price  = game['moneyline']['away_line']   || 0
      else home_price = away_price = 0;   end

      if game['spread']
        home_spread = game['spread']['home_price']     || 0
        away_spread = game['spread']['away_price']     || 0
      else home_spread = away_spread = 0; end

      game['stats'] = {}
      game['stats']['over_payout']  = over_price  < 0 ? -100/over_price  : over_price /100
      game['stats']['under_payout'] = under_price < 0 ? -100/under_price : under_price/100
      game['stats']['home_payout']  = home_price  < 0 ? -100/home_price  : home_price /100
      game['stats']['away_payout']  = away_price  < 0 ? -100/away_price  : away_price /100
      game['stats']['home_spread']  = home_spread < 0 ? -100/home_spread : home_spread/100
      game['stats']['away_spread']  = away_spread < 0 ? -100/away_spread : away_spread/100

      game['max_amount'] = game['stats'].values.max
      game['max_payout'] = game['stats'].key(game['max_amount'])

      @points += game['max_amount']
    end

    #Sum all the points and divide by the available chips = chips_per_point.
    @chips_per_point =  @chips / @points

    #For each game, bet points*chips_per_point on the highest payout.
    @events.each do |game|
      unless @chips_per_point * game['max_amount'] < 10
        pick = game['max_payout'].include?('home') ? 1 : 2

        wager = (@chips_per_point * game['max_amount']).to_i

        bet_line =
          if    game['max_payout'].include?('over' || 'under') then 'overunder'
          elsif game['max_payout'].include?('payout')          then 'moneyline'
          elsif game['max_payout'].include?('spread')          then 'spread'
          else nil; end

        while wager > 100
          #take care of the corner case of e.g. 109: 
          #won't be able to bet 9 leftover chips
          wager_fraction = wager < 110 ? 90 : 100

          RestClient.post(beturl, :event_id => game['id'],
                          :bet_line_type => bet_line, :pick => pick,
                          :wager => wager_fraction, :api_key => api_key)
          wager -= wager_fraction
        end

        RestClient.post(beturl, :event_id => game['id'],
                        :bet_line_type => bet_line, :pick => pick,
                        :wager => wager, :api_key => api_key)
      end
    end
  end

  haml :index
end
