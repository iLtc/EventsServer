class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @events = Event.where('first_date > ?', Time.now - 1.hour).order('first_date ASC')
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

    temp = user.liked_events.new
    temp.event = event
    temp.save
  end

  def unlike
    event = Event.where('eid = ?', params[:eid]).first
    user = User.where('uid = ?', params[:id]).first

    LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id).first.destroy
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