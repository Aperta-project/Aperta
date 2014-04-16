class JournalsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    respond_with Journal.all
  end

  def show
    respond_with Journal.find(params[:id])
  end
end
