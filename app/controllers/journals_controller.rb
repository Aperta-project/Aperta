class JournalsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    authorize_action!
    respond_with Journal.all
  end

  def show
    authorize_action!(journal: journal)
    respond_with journal
  end

  private

  def journal
    Journal.find(params[:id])
  end

end
