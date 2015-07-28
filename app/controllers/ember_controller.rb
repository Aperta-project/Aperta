class EmberController < ApplicationController
  respond_to :html
  layout 'ember'

  before_action :store_location

  def index
  end
end
