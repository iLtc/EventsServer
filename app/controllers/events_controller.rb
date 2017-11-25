class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @events = Event.where('last_date > ?', Time.now).order('first_date ASC')
  end

  def detail
    @event = Event.where('eid = ?', params[:eid]).first

    @photos = ActiveSupport::JSON.decode @event[:photos]
    puts @photos
  end

  def categories
    temp = EventCategory.order('title')

    @categories = []
    temp.each do |category|
      @categories << category[:title]
    end
  end

  def like
    event = Event.where('eid = ?', params[:eid]).first
    user = User.where('uid = ?', params[:id]).first

    unless LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id).count > 0
      temp = user.liked_events.new
      temp.event = event
      temp.save
    end
  end

  def unlike
    event = Event.where('eid = ?', params[:eid]).first
    user = User.where('uid = ?', params[:id]).first

    temp = LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id)
    temp.first.destroy if temp.count > 0
  end

  def upload
    s3 = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(ENV['AWS_ACCESS_ID'], ENV['AWS_SECRET_KEY']),
        region: 'us-east-2'
    )
    obj = s3.bucket(ENV['S3_BUCKET']).object('key')
    obj.upload_file('/path/to/source/file')
    puts params
  end
end