require 'httparty'

class Uiowa
  def self.get_events(page=1)
    url = 'https://events.uiowa.edu/api/2/events?page=' + page.to_s
    response = HTTParty.get(url)
    response.parsed_response
  end

  def self.events
    events = []
    page = 1

    loop do
      result = get_events(page)

      result['events'].each { |event| events << event }

      if page < result['page']['total']
        page += 1
      else
        break
      end
    end

    events
  end


end