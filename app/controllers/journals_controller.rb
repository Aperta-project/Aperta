class JournalsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    respond_with current_user.admin_journals
  end

  def show
    respond_with Journal.find(params[:id])
  end
end
