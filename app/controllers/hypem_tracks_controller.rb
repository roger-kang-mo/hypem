class HypemTracksController < ApplicationController

  respond_to :json

  def index
    entity params[:type] == "user" ? HypemUser.find()
    user = HypemUser.where()
  end
end