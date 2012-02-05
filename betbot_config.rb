# when running locally, the API key will be taken from the local_api_key file,
# which is gitignored.
# before uploading to e.g. heroku, run the following:
  # heroku config:add API_KEY=my_api_key
API_KEY = ENV['API_KEY'] || File.read(File.join(File.dirname(__FILE__), 'local_api_key')).strip

WTT_URL          = "http://winthetrophy.com/apiv1" #"http://localhost:3000/apiv1"
CURRENT_BET_WEEK = "#{WTT_URL}/bet_weeks.json?time=#{Time.now.to_i}&api_key=#{API_KEY}"
EVENTS           = "#{WTT_URL}/events.json?api_key=#{API_KEY}"
BET_URL          = "#{WTT_URL}/bets"
STATUS           = 'ok' # should be ok unless something is broken
THRESHOLD        = 1500 # quit while you're ahead (over this threshold)

