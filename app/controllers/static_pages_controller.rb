class StaticPagesController < ApplicationController
  before_action :set_flickr, only: [:home]
  def home
    if params[:commit]
      @user_id = params[:flickr_user_id]
      if @user_id.empty?
        flash.now[:danger] = 'Enter the id.'
      else
        @user_profile = user_profile
        if @user_profile.nil?
          flash.now[:danger] = 'No such user.'
        else
          @user_name = user_name
          @photos = user_photos
          flash.now[:danger] = 'No photos have been uploaded yet.' if @photos.nil?
        end
      end
    end
  end

  def about; end

  private

  def set_flickr
    FlickRaw.api_key = ENV['API_KEY']
    FlickRaw.shared_secret = ENV['SHARED_SECRET']

    flickr.access_token = ENV['ACCESS_TOKEN']
    flickr.access_secret = ENV['ACCESS_SECRET']
  end

  def user_photos
    flickr = FlickRaw::Flickr.new
    flickr.photos.search(user_id: @user_id, per_page: 15).to_a
  rescue Exception
    nil
  end

  def user_name
    user_info = flickr.profile.getProfile(user_id: @user_id)
    "#{user_info['first_name']} #{user_info['last_name']}"
  rescue Exception
    nil
  end

  def user_profile
    user_link = flickr.urls.getUserProfile(user_id: @user_id)
    user_link['url']
  rescue Exception
    nil
  end
end
