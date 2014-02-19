require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/json'

require 'dalli'

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

  get '/' do
    redirect to('/calendar.json?keyword=memphis+ruby')
  end

  get '/calendar.json' do
    keyword = params[:keyword]

    json meetups: scraper.by_keyword(keyword)
  end

  def scraper
    Scraper.new(cache: cache)
  end

  def cache
    settings.cache
  end

  run! if app_file == $0
end
