class HypemController < ApplicationController
  include HypemHelper

  def index
    @hypem_tracks = HypemTrack.page(0)

    respond_to do |format|
      format.html
    end
  end

  def query_tracks
    username = params[:username]

    HypemUser.create({username: username}) unless HypemUser.find_by_username(username)

    data = get_songs_for_user(username)

    respond_to do |format|
      if data.is_a?(Hash) && data[:error]
        format.json { render :json => data, :status => 500 }
      else
        format.json { render :json => data }
      end
    end
  end

  def get_library
    data = HypemTrack.page(params[:page])

    respond_to do |format|
      format.json { render :json => data }
    end
  end
end