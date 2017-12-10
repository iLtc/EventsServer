json.extract! event, :eid, :title, :url, :first_date, :last_date, :all_day, :location, :description, :liked, :owned, :likes
json.first_date event[:first_date].to_time.iso8601

if event[:last_date].nil?
  json.last_date (event[:first_date].to_time + 30.minutes).iso8601
else
  json.last_date event[:last_date].to_time.iso8601
end

json.views event.views1
json.photos ActiveSupport::JSON.decode event[:photos]
json.geo ActiveSupport::JSON.decode event[:geo]
json.categories ActiveSupport::JSON.decode event[:categories]