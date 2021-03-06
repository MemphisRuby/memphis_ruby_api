require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/json'

require 'newrelic_rpm'

require 'dalli'
require 'rack/cors'

require './scraper'

class ApiApp < Sinatra::Base
  set :cache, Dalli::Client.new(
      ENV.fetch("MEMCACHIER_SERVERS", 'localhost').split(","),
      {:username => ENV["MEMCACHIER_USERNAME"],
       :password => ENV["MEMCACHIER_PASSWORD"],
       :failover => true,
       :socket_timeout => 1.5,
       :socket_failure_delay => 0.2
    })

  use Rack::Cors do
    allow do
      origins '*'
      resource '/calendar.json', :headers => :any, :methods => :get
    end
  end


  get '/' do
    redirect to('/calendar.json?keyword=memphis+ruby')
  end

  get '/calendar.json' do
    keyword = params[:keyword]

    json({
      "_pull_requests_appreciated" => "https://github.com/MemphisRuby/memphis_ruby_api",
      "meetups" => scraper.by_keyword(keyword),
    })
  end

  # Wildcard route that redirects to the matching meetups next event url.
  get '/:meetup' do
    keyword = params[:meetup]
    if result = scraper.by_keyword(keyword).first
      redirect to(result["event_url"])
    else
      redirect to('http://www.meetup.com/memphis-technology-user-groups/')
    end
  end

  def scraper
    Scraper.new(cache: cache)
  end

  def cache
    settings.cache
  end

  run! if app_file == $0
end
