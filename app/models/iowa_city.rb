require 'httparty'
require 'nokogiri'

class IowaCity
  def self.get_events(page = 1, date = DateTime.now)
    page -= 1
    date = date.strftime('%Y-%m-%d')
    url = 'https://www.icgov.org/events/list/%s--%s?page=%d' % [date, date, page]

    response = HTTParty.get(url)
    doc = Nokogiri::HTML response.body

    events = []

    doc.css('article:not(.alert)').each do |event|
      temp = {
          :eid => 'IC-' + Digest::MD5.new.to_s,
          :title => event.at_css('h2 a').text.strip,
          :url => 'https://www.icgov.org' + event.at_css('h2 a')['href'],
          :first_date => DateTime.parse(event.at_css('.date-display-single')['content']),
          :last_date => nil,
          :location => event.at_css('.addressfield-container-inline').text.strip,
          :description => event.at_css('.field--name-field-event-description').text.strip,
          :photos => ['https://upload.wikimedia.org/wikipedia/en/1/1d/City_of_Iowa_City_logo.png'],
          :geo => get_geo(event.at_css('.addressfield-container-inline').text.strip + ', Iowa City, IA').to_json,
          :all_day => false
      }

      categories = []
      for type in event.css('.field--name-field-event-categories .field-item') do
        categories << type.at_css('a').text.strip
        EventCategory.add type.at_css('a').text.strip
      end

      temp[:categories] = categories

      events << temp
    end

    events
  end

  def self.get_geo(address)
    response = HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?address=%s&key=%s' % [address, 'AIzaSyCg6tNKz8buHSdIOITIvC6sLRqWjPUYXXQ'])
    temp = response.parsed_response

    if temp['results'].length > 0
      result = {
          :latitude => temp['results'][0]['geometry']['location']['lat'],
          :longitude => temp['results'][0]['geometry']['location']['lng']
      }
    else
      result = {
          :latitude => '',
          :longitude => ''
      }
    end

    result
  end

  def self.events
    page = 1

    result = get_events(page)

    result
  end

  def self.save(events)
    for event in events do
      unless Event.where('url = ?', event[:url]).count > 0
        Event.create(event)
      end
    end
  end

  def self.sync
    events = events()
    save(events)
  end
end