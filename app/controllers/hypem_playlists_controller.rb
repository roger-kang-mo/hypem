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
    page = params[:page] || 0
    params[:seed] ||= Random.new_seed
    srand params[:seed].to_i
    @playlist = HypemPlaylist.find(params[:id]).hypem_track.all
    @playlist = Kaminari.paginate_array(@playlist).page(page).per(25)

    respond_with @playlist
  end
end