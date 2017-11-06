json.extract! event, :eid, :title, :url, :first_date, :location, :description
json.photos ActiveSupport::JSON.decode event[:photos]
json.geo ActiveSupport::JSON.decode event[:geo]
json.categories ActiveSupport::JSON.decode event[:categories]