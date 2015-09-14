require 'sinatra'
require 'json'
require 'net/http'
require 'time'

get '/' do
  content_type :json
  data = Net::HTTP.get URI('http://efa.mvv-muenchen.de/ultralite/XSLT_DM_REQUEST?coordOutputFormat=WGS84&type_dm=stop&name_dm=regerplatz&mode=direct&limit=10&useRealtime=1')
  data = JSON.parse(data)
  departures = data["departures"]
  now = data["now"]
  if departures && now
    times = get_times(departures, now)
    times.to_json
  else
    "error"
  end
end

def get_times(departures, now)
  # TODO:
  # for cleaner code, replace with while loop that stops
  # when the times hash is filled
  times = { 23062 => { "H" => nil, "R" => nil}, 23125 => {"H" => nil, "R" => nil } }

  for departure in departures
    details = get_route_details(departure)
    line = details[:line]
    direction = details[:direction]
    unless times[line][direction]
      times[line][direction] = (Time.parse(details[:time]) - Time.parse(now)).to_i
    end
  end

  times
end

def get_route_details(departure)
  {
    line: departure["mode"]["diva"]["line"],
    direction: departure["mode"]["diva"]["direction"],
    time: departure["dateTime"]["time"]
  }
end