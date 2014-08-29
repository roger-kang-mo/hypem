class EmailsController < ApplicationController

  respond_to :json

  before_filter :allow_shit

  def add_email
    email = params[:email]
    plan = params[:plan]
    omment = params[:omment]
    @email = Email.where(email: email, plan: plan, omment: omment).first

    @email = Email.create(email: email, plan: plan, omment: omment) unless @email
    respond_with @email
  end

  private
  def allow_shit
    headers['Access-Control-Allow-Origin'] = '0.0.0.0:8000'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end