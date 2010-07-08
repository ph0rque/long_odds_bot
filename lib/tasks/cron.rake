require '../../betbot_strategy'

task :cron => :environment do
  bet_on_games
end
