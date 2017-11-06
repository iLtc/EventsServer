class EventsController < ApplicationController
  def index
    events = Event.all

    (0...events.length).each do |index|
      events[index][:photos] = ActiveSupport::JSON.decode events[index][:photos]
      events[index][:geo] = ActiveSupport::JSON.decode events[index][:geo]
      events[index][:categories] = ActiveSupport::JSON.decode events[index][:categories]
      puts events[index][:categories]
    end

    @events = events
  end
end
