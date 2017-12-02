class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @events = Event.where('last_date > ?', Time.now).order('first_date ASC')

    unless params[:uid].nil?
      user = User.where('uid = ?', params[:uid]).first

      @events.each do |event|
        if LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id).count > 0
          event.liked = true
        else
          event.liked = false
        end

        if OwnedEvent.where('user_id = ? and event_id = ?', user.id, event.id).count > 0
          event.owned = true
        else
          event.owned = false
        end
      end
    end
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
    file_name = params[:fileset].path.split('/').last

    s3 = Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_ID'], ENV['AWS_SECRET_KEY']),
      region: 'us-east-2'
    )
    obj = s3.bucket(ENV['S3_BUCKET']).object(file_name)
    obj.upload_file(params[:fileset].path)

    @url = obj.public_url
  end

  def new
    temp = {
        :eid => 'ES-' + SecureRandom.hex,
        :title => params[:title],
        :first_date => DateTime.parse(params[:date]),
        :last_date => DateTime.parse(params[:endDate]),
        :location => params[:location],
        :description => params[:description],
        :photos => [params[:photo]],
        :geo => {
          :latitude => params[:la].sub('Optional(', '').sub(')', ''),
          :longitude => params[:lo].sub('Optional(', '').sub(')', '')
        }.to_json,
        :all_day => false,
        :categories => ['Events Map']
    }

    @event = Event.create(temp)

    unless params[:uid].nil?
      user = User.where('uid = ?', params[:uid]).first
      temp = user.owned_events.new
      temp.event = @event
      temp.save
    end
  end
end