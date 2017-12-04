class Event < ApplicationRecord
  has_many :liked_events
  has_many :owned_events

  attr_accessor :liked, :owned

  def likes
    # TODO: Find a better way
    LikedEvent.where('event_id = ?', id).count
  end
end
