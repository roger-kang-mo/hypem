class HypemUsersController < ApplicationController

  respond_to :json

  def index
    @users = HypemUser.all

    @users

    respond_with @users
  end
end