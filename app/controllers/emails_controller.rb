class EmailsController < ApplicationController

  before_filter :allow_shit

  def index
    @emails = Email.all

    respond_to do |format|
      format.html
    end
  end

  def add_email
    email = params[:email]
    plan = params[:plan]
    comment = params[:comment]
    @email = Email.where(email: email, plan: plan, comment: comment).first

    @email = Email.create(email: email, plan: plan, comment: comment) unless @email
    respond_to do |format|
      format.json { render :json => @email }
    end
  end

  private
  def allow_shit
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end