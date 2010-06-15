WTT_URL   = 'http://www.winthetrophy.com/apiv1'

# Put your API Key in a file called ./api.key
API_KEY = File.read(File.join(File.dirname(__FILE__), 'api.key'))

BET_WEEKS = "#{WTT_URL}/bet_weeks.json?api_key=#{API_KEY}"
EVENTS    = "#{WTT_URL}/events.json?api_key=#{API_KEY}"
BET_URL   = "#{WTT_URL}/bets"

STATUS    = 'ok' #should be ok unless something is broken

