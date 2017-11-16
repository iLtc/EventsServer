class EventsController < ApplicationController
  def index
    @events = Event.where('first_date > ?', Time.now - 1.hour).order('first_date ASC')
  end

  def detail
    @event = Event.where('eid = ?', params[:eid]).first

    @photos = ActiveSupport::JSON.decode @event[:photos]
    puts @photos
  end
end
