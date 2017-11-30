class User < ApplicationRecord
  has_many :logins
  has_many :liked_events
  has_many :owned_events
end
