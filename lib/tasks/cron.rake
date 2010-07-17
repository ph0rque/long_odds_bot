require 'betbot_config'
require 'betbot_strategy'

task :cron do
  puts 'Making daily bets...'
  bet_on_games
  puts '...done.'
end
