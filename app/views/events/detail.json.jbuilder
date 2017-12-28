json.code 200
json.msg ''
json.event do
  json.partial! 'events/event', event: @event
end