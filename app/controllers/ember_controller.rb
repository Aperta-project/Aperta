class EmberController < ApplicationController
  respond_to :html
  layout 'ember'

  before_action :store_location

  def index
  end

  private

  def store_location
    store_location_for(:user, request.original_fullpath)
  end
end
