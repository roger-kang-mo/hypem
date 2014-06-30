class HypemController < ApplicationController
  include HypemHelper

  def index
    seed = params[:seed]
    @seed ||= Random.new_seed
    respond_to do |format|
      format.html
    end
  end

  # def search
  #   @q = HypemTrack.search(params[:q])
  #   @people = @q.includes(:hypem_users).includes(:hypem_playlists).result(distinct: true)
  # end

  def get_tracks
    list_name = params[:query]

    if list_name == "hypemmain"
      @tracks = paginate_tracks(list_name, params[:page])
    elsif list_name
      user = HypemUser.where('username = ? OR fake_name = ?', list_name, list_name).first
      user = HypemUser.create({username: list_name, fake_name: get_random_name}) unless user
      @tracks = params[:force_check] ? get_songs_for_user(user) : paginate_tracks(user, params[:page])
      @fake_name = user.fake_name
      @finished = @tracks.length == 0 ? true : false
    end

    respond_to do |format|
      format.json { render :json => { tracks: @tracks, fake_name: @fake_name, finished: @finished } }
    end
  end

  private

  def paginate_tracks(user, page = 0)
    # console.log "here #{page}"
    params[:seed] ||= Random.new_seed
    srand params[:seed].to_i
    if user == "hypemmain"
      Kaminari.paginate_array(HypemTrack.all.shuffle).page(page).per(25)
    else
      Kaminari.paginate_array(user.hypem_tracks.all.shuffle).page(page).per(25)
    end
  end
end