require './lookup_cache.rb'

class Scraper
  def initialize(cache: nil)
    @cache = cache
    self
  end

  attr_reader :cache

  def by_keyword(keyword)
    all_meetups.select do |meetup|
      meetup.fetch("name") =~ /#{keyword.to_s.strip}/i
    end
  end

  private
  def fetcher
    LookupCache.new(cache: cache)
  end

  def all_meetups
    fetcher.lookup(meetup_url)
  end

  def meetup_url
    ENV.fetch("MEETUP_URL")
  end
end
