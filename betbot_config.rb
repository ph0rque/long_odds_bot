# when running locally, the API key will be taken from the local_api_key file,
# which is gitignored.
# before uploading to e.g. heroku, run the following:
  # heroku config:add API_KEY=my_api_key
API_KEY   = ENV['API_KEY'] or File.read(File.join(File.dirname(__FILE__), 'local_api_key'))

WTT_URL   = 'http://www.winthetrophy.com/apiv1'
BET_WEEKS = "#{WTT_URL}/bet_weeks.json?api_key=#{API_KEY}"
EVENTS    = "#{WTT_URL}/events.json?api_key=#{API_KEY}"
BET_URL   = "#{WTT_URL}/bets"
STATUS    = 'ok' # should be ok unless something is broken

