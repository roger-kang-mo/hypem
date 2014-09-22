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
      #binding.pry
      @tracks = paginate_tracks(list_name, params[:page])
    elsif list_name
      page = params[:page] || 0
      user = HypemUser.where('username = ? OR fake_name = ?', list_name, list_name).first
      user = HypemUser.create({username: list_name, fake_name: get_random_name}) unless user
      # binding.pry
      if params[:force_check] == "false" && user.hypem_tracks.count > 0
        @tracks = paginate_tracks(user, params[:page])
      else
        get_songs_for_user(user)
        @tracks = user.hypem_tracks.page(page).per(25)
      end

      @fake_name = user.fake_name

      @finished = @tracks.length == 0 ? true : false
    end

    @track_data = { tracks: @tracks, fake_name: @fake_name, finished: @finished }

    respond_to do |format|
      format.json { render :json => @track_data }
    end
  end

  private

  def paginate_tracks(user, page = 0)
    params[:seed] ||= Random.new_seed
    srand params[:seed].to_i
    tracks = []
    if user == "hypemmain"
      tracks = Kaminari.paginate_array(HypemTrack.all.shuffle).page(page).per(25)
    else
      # tracks = Kaminari.paginate_array(user.hypem_tracks.all.shuffle).page(page).per(25)
      tracks = user.hypem_tracks.page(page).per(25)
    end

    tracks
  end
end
