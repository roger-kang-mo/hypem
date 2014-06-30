class HypemPlaylistsController < ApplicationController

  respond_to :json

  def index
    @playlists = HypemPlaylist.all

    respond_with @playlists
  end

  def create
    @playlist = HypemPlaylist.create(params[:playlist])

    respond_with @playlist
  end

  def show
    @playlist = HypemPlaylist.find(params[:id])

    respond_with @playlist
  end
end