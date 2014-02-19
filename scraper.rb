require 'httparty'

class Scraper
  def rubies
    all_meetups.select{ |r| r.fetch("name") =~ /Memphis Ruby/ }
  end

  private
  def all_meetups
    response = HTTParty.get(meetup_url)

    response.fetch("results")
  end

  def meetup_url
    ENV.fetch("MEETUP_URL")
  end
end
