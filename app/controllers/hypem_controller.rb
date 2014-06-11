class HypemController < ApplicationController
  include HypemHelper

  def index
    seed = params[:seed]
    @seed ||= Random.new_seed
    respond_to do |format|
      format.html
    end
  end

  def get_users
    @users = HypemUser.all.collect { |user| { username: user.username, fake_name:user.fake_name } }

    respond_to do |format|
      format.json { render :json => @users }
    end
  end

  def get_tracks
    list_name = params[:query]
    @data = {}

    if list_name == "hypemmain"
      @data[:tracks] = get_library(params[:page])
    elsif list_name
      user = HypemUser.where('username = ? OR fake_name = ?', list_name, list_name).first
      user = HypemUser.create({username: list_name, fake_name: get_random_name}) unless user
      @data[:tracks] = params[:force_check] ? get_songs_for_user(user) : user.hypem_tracks
      @data[:fake_name] = user.fake_name
    end

    respond_to do |format|
      if @data.is_a?(Hash) && @data[:error]
        format.json { render :json => @data, :status => 500 }
      else
        format.json { render :json => @data }
      end
    end
  end

  private

  def get_library(page = 0)
    params[:seed] ||= Random.new_seed
    srand params[:seed].to_i
    Kaminari.paginate_array(HypemTrack.all.shuffle).page(page).per(25)
  end
end