require 'httparty'
require 'date'

class LookupCache
  def initialize(cache: nil)
    @cache = cache
  end

  attr_reader :cache

  def lookup(url)
    key = request_key(url)

    cache.get(key) || fill_cache(url, key)
  end

  def fill_cache(url, key)
    puts "Setting #{key}"
    result = HTTParty.get(url).fetch("results")
    cache.set(key, result)
    result
  end

  def request_key(request)
    [datemask, request].join('-')
  end

  def datemask
    DateTime.now.strftime("%Y%m%d%H%M")
  end
end
