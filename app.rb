require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sinatra/json'
require './scraper'

get '/' do
  json meetups: scraper.rubies
end

def scraper
  Scraper.new
end
