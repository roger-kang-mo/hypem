class HypemUsersController < ApplicationController

  respond_to :json

  def index
    @users = HypemUser.all

    respond_with @users
  end
end