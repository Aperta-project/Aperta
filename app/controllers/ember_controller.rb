class EmberController < ApplicationController
  before_action :authenticate_user!

  respond_to :html
  layout 'ember'

  def index
  end
end
