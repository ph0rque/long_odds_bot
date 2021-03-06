require 'json'
require 'rest_client'

def bet_on_games
  #Get # of chips for the current betweek.
  #If less than ten, you're done until the next time you check.
  @current_bet_week = JSON.parse(RestClient.get(CURRENT_BET_WEEK).body)
  @chips_available  = @current_bet_week[0]['chips_available']
  @points           = 0
  @chips_per_point  = 0
  @chips            = @current_bet_week[0]['chips']
  
  unless @chips_available < 10 or @chips > THRESHOLD
    #Get all the games in the next 24 hours.
    @events = JSON.parse(RestClient.get(EVENTS).body)

    # For each game, determine the max payout; record the points for it.
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

    #no events were available, so we don't have anything to bet
    unless @points == 0
      #Sum all the points and divide by the available chips = chips_per_point.
      @chips_per_point =  @chips_available / @points

      #For each game, bet the amount of points determined, if any
      @events.each do |game|
        # bet points*chips_per_point on the highest payout.
        unless @chips_per_point * game['max_amount'] < 10
          pick = game['max_payout'].include?('home') ? 1 : 2

          wager = (@chips_per_point * game['max_amount']).to_i

          bet_line =
            if    game['max_payout'].include?('over' || 'under') then 'over_under'
            elsif game['max_payout'].include?('payout')          then 'moneyline'
            elsif game['max_payout'].include?('spread')          then 'spread'
            else nil; end

          while wager > 100
            #take care of the corner case of e.g. 109: 
            #won't be able to bet 9 leftover chips
            wager_fraction = wager < 110 ? 90 : 100

            RestClient.post(BET_URL, :event_id => game['id'],
                            :bet_line_type => bet_line, :pick => pick,
                            :wager => wager_fraction, :api_key => API_KEY)
            wager -= wager_fraction
          end

          RestClient.post(BET_URL, :event_id => game['id'],
                          :bet_line_type => bet_line, :pick => pick,
                          :wager => wager, :api_key => API_KEY)
        end
      end
    end       
  end
end

