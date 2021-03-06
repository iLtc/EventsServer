class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    pid = params[:pid]
    platform = params[:platform]
    name = params[:name]
    pic_url = params[:picURL]

    temp = Login.where('pid = ? and platform = ?', pid, platform)
    if temp.count > 0
      login = temp.first
      user = login.user

      if user.name != name or user.pic_url != pic_url
        user.name = name
        user.pic_url = pic_url
        user.save
      end
    else
      user = User.new
      user.uid = SecureRandom.hex
      user.name = name
      user.pic_url = pic_url
      user.save

      login = user.logins.new
      login.pid = pid
      login.platform = platform
      login.save
    end

    @user = user
  end
end
