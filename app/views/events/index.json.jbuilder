json.code 200
json.msg ''
json.events do
  json.array! @events, partial: 'events/event', as: :event
end