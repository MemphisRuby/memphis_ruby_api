require 'httparty'
require 'date'
require 'base64'
require 'pry'

class LookupCache
  def initialize(cache: nil)
    @cache = cache
  end

  attr_reader :cache

  def lookup(urls)
    key = request_key(urls)

    cache.get(key) || fill_cache(urls, key)
  end

  def fill_cache(urls, key)
    puts "Setting #{key}"
    results = []

    urls.each do |url|
      resp   = HTTParty.get(url)
      begin
      result = resp.fetch("results")
      rescue KeyError => err
        puts "*** Unexpected JSON results!"
        puts err.message
        puts resp
        puts "***"
      end
      results << result
    end

    results = results.flatten.sort_by { |r| r["time"] }

    cache.set(key, results)
    results
  end

  def request_key(request)
    hashed = Base64.encode64(request.to_s)
    [datemask, hashed].join('-')
  end

  def datemask
    DateTime.now.strftime("%Y%m%d%H%M")
  end
end
