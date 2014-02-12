class HypemController < ApplicationController
  include HypemHelper

  def index
    respond_to do |format|
      format.html
    end
  end

  def query_tracks
    data = get_songs_for_user(params[:username])

    respond_to do |format|
      format.json { render :json => data }
    end
  end
end