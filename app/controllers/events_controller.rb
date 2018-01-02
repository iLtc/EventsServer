class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    temp = Event.where('last_date > ? AND verified = ?', Time.now, true)

    if temp.size == 0
      render_error(404, 'No Event') and return
    end

    @events = []

    unless params[:categories].nil?
      request_categories = params[:categories].split(',')
    end

    unless params[:sources].nil?
      request_sources = []

      params[:sources].split(',').each do |source|
        request_sources << "UI" if source == "University of Iowa"
        request_sources << "IC" if source == "Iowa City"
        request_sources << "ES" if source == "Events Server"
      end
    end

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

    if @events.size.zero?
      render_error(404, 'No Event Base On Filter') and return
    end

    unless params[:uid].nil?
      user = get_user params[:uid]
      return if performed?

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

    if params[:sort].nil?
      @events.sort_by! { |event| [event[:first_date], event[:last_date]] }
    else
      case params[:sort]
        when "End Time"
          @events.sort_by! { |event| [event[:last_date], event[:first_date]] }
        when "Most Viewed"
          @events.sort_by! { |event| [-event.views1, event[:first_date]] }
        when "Most Liked"
          @events.sort_by! { |event| [-event.likes, event[:first_date]] }
        else # when "Start Time"
          @events.sort_by! { |event| [event[:first_date], event[:last_date]] }
      end
    end
  end

  def detail
    temp = Event.where('eid = ?', params[:eid])

    if temp.size.zero?
      respond_to do |format|
        format.html {render "detail_notfound"}
        format.json { render_error(404, "Event Not Found") }
      end
      return
    end

    @event = temp.first

    @photos = ActiveSupport::JSON.decode @event[:photos]
  end

  def categories
    temp = EventCategory.order('title')

    @categories = []
    temp.each do |category|
      @categories << category[:title]
    end
  end

  def like
    user = get_user params[:uid]
    return if performed?

    event = get_event params[:eid]
    return if performed?

    if LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id).count > 0
      render_error(400, 'You already liked this event.')
      return
    end

    temp = user.liked_events.new
    temp.event = event
    temp.save

    render 'events/done'
  end

  def unlike
    user = get_user params[:uid]
    return if performed?

    event = get_event params[:eid]
    return if performed?

    temp = LikedEvent.where('user_id = ? and event_id = ?', user.id, event.id)

    if temp.count.zero?
      render_error(400, 'You haven\'t liked this event.')
      return
    end

    temp.first.destroy

    render 'events/done'
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
    user = get_user params[:uid]
    return if performed?

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

    temp[:url] = 'https://api.events.iltcapp.net/events/' + temp[:eid]

    @event = Event.create(temp)

    temp = user.owned_events.new
    temp.event = @event
    temp.save
  end

  def user_events
    user = get_user params[:uid]
    return if performed?

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

    @events.sort_by! { |event| [event[:first_date], event[:last_date]] }

    render "index"
  end

  def views
    event = get_event params[:eid]
    return if performed?

    event.increment! :views

    render "done"
  end

  def delete
    user = get_user params[:uid]
    return if performed?

    event = get_event params[:eid]
    return if performed?

    if OwnedEvent.where('user_id = ? AND event_id = ?', user.id, event.id).count == 0
      render_error(403, 'User Not Own Event') and return
    end

    LikedEvent.where('event_id = ?', event.id).destroy_all
    OwnedEvent.where('event_id = ?', event.id).destroy_all

    event.destroy

    render json: { code: 200, msg: '' }
  end

  private

  def get_user(uid)
    temp = User.where('uid = ?', uid)

    if temp.count.zero?
      render_error(404, 'No User') and return
    end

    temp.first
  end

  def get_event(eid)
    temp = Event.where('eid = ?', eid)

    if temp.count.zero?
      render_error(404, 'No Event') and return
    end

    temp.first
  end

  def render_error(code, msg)
    render json: { code: code, msg: msg }
  end
end