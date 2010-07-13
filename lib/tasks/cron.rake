require 'betbot_strategy'

task :cron => :environment do
  puts 'Making daily bets...'
  bet_on_games
  puts '...done.'
end
