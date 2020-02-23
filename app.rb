require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "a685c94f4e6b1598058e0bc03b6477a3"
news = HTTParty.get("https://newsapi.org/v2/top-headlines?country=us&apiKey=e3005a3e70664d649fa202124940be3b").parsed_response.to_hash

get "/" do
  view "ask"
end

get "/results" do
    view "results"
end

get "/news" do 
    unless params["location"].empty?
        results = Geocoder.search(params["location"])

        unless results.first.nil?
            
            @lat_long = results.first.coordinates
            @lat = @lat_long[0]
            @long = @lat_long[1]
            @coordinates = "#{@lat}, #{@long}"
            
            forecast = ForecastIO.forecast("#{@lat}", "#{@long}").to_hash
            @timezone = forecast["timezone"]
            @current_temp = forecast["currently"]["temperature"]
            @current_conditions = forecast["currently"]["summary"]
            
            @masterarrayweather = Array.new
            i=0
            require 'date'
            for day in forecast["daily"]["data"]
                @masterarrayweather[i] = [Time.at(day["time"]).strftime("%m/%d/%Y"),day["temperatureHigh"],day["summary"]]
                i = i+1
            end

            @masterarraynews = Array.new
            i=0
            for a in news["articles"]
                @masterarraynews[i] = [a["title"],a["url"]]
                i=i+1
            end
            view "news"

        else 
            "Your location was not valid, please go back and try again."
        end

    else
        "Please go back and enter a location to show a result."
    end
end