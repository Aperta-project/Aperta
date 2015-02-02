class EmberController < ApplicationController
  respond_to :html
  layout 'ember'
  def index
    #do nothing
  end

  def styleguide
    render layout: 'layouts/styleguide'
  end
end
