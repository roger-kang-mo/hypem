class HypemTracksController < ApplicationController

  respond_to :json

  def index
    # entity params[:type] == "user" ? HypemUser.find()
    # user = HypemUser.where()
  end

  def add_to_playlist
    @hypem_track = HypemTrack.find(params[:id])
    playlist = HypemPlaylist.find(params[:playlist_id])

    @hypem_track.hypem_playlist << playlist unless @hypem_track.hypem_playlist.include? playlist
  end
end