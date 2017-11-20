class EventCategory < ApplicationRecord
  def self.add(title)
    if EventCategory.where('title = ?', title).count.zero?
      EventCategory.create(title: title)
    end
  end
end