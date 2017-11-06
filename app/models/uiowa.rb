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

      result['events'].each { |event| events << event['event'] }

      if page < result['page']['total']
        page += 1
      else
        break
      end
    end

    events
  end

  def self.format(events)
    formatted = []

    for event in events do
      temp = {
        :eid => 'UI-' + event['id'].to_s + '-' + event['event_instances'][0]['event_instance']['id'].to_s,
        :title => event['title'],
        :url => event['localist_url'],
        :first_date => event['event_instances'][0]['event_instance']['start'],
        :last_date => nil,
        :location => event['location_name'],
        :description => event['description_text'],
        :photos => [event['photo_url']],
        :geo => {
          :latitude => event['geo']['latitude'],
          :longitude => event['geo']['longitude']
        }.to_json
      }

      categories = []
      if event['filters'].has_key?('event_types')
        for type in event['filters']['event_types'] do
          categories << type['name']
        end
      end
      temp[:categories] = categories

      formatted << temp
    end

    formatted
  end

  def self.save(events)
    for event in events do
      unless Event.where('eid = ?', event[:eid]).count > 0
        Event.create(event)
      end
    end
  end

  def self.sync
    events = events()
    formatted = format(events)
    save(formatted)
  end
end