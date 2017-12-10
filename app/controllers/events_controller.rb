class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    # TODO: Change limit and order
    temp = Event.where('last_date > ?', Time.now - 1.day).order('first_date ASC')

    @events = []

    unless params[:categories].nil?
      request_categories = params[:categories].split(',')
    end
    puts request_categories

    unless params[:sources].nil?
      request_sources = []

      params[:sources].split(',').each do |source|
        request_sources << "UI" if source == "University of Iowa"
        request_sources << "IC" if source == "Iowa City"
        request_sources << "ES" if source == "Events Server"
      end
    end
    puts request_sources

    (0...(temp.size)).each do |i|
      unless params[:categories].nil?
        event_categories = ActiveSupport::JSON.decode temp[i][:categories]
        next if (request_categories & event_categories).empty?
      end

      unless params[:sources].nil?
        next unless request_sources.include? temp[i][:eid].slice(0, 2)
      end

      @events << temp[i]
    end


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

    temp[:url] = 'https://events.iltcapp.net/events/' + temp[:eid]

    @event = Event.create(temp)

    unless params[:uid].nil?
      user = User.where('uid = ?', params[:uid]).first
      temp = user.owned_events.new
      temp.event = @event
      temp.save
    end
  end

  def user_events
    unless params[:uid].nil?
      user = User.where('uid = ?', params[:uid]).first
      @events = []

      owneds = user.owned_events
      owneds.each do |owned|
        @events << owned.event
      end

      likeds = user.liked_events
      likeds.each do |liked|
        @events << liked.event
      end

      @events.uniq!

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
    render "index"
  end

  def views
    unless params[:eid].nil?
      temp = Event.where('eid = ?', params[:eid])

      unless temp.count == 0
        event = temp.first

        event.increment! :views
      end
    end
  end
end