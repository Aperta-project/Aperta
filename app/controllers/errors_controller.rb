class ErrorsController < ApplicationController
  before_action :authenticate_user!

  def create
    logger.warn "JS error for user #{current_user.id}"
    logger.warn params[:message]
    head 204
  end
end
