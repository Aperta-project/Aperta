class JournalsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    render json: Journal.all
  end
end
