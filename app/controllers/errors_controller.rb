class ErrorsController < ApplicationController
  before_action :authenticate_user!

  def create
    logger.warn params[:message]
  end
end
