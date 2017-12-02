class Event < ApplicationRecord
  has_many :liked_events
  has_many :owned_events

  attr_accessor :like, :own
end
