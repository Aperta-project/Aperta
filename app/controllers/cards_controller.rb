class CardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    respond_with owner_klass.find(params[:owner_id]).card
  end

  def index
    respond_with Card.find_by(name: params[:name])
  end

  private

  def owner_klass
    potential_owner = params[:owner_type].to_s.gsub("::", "/").classify.constantize
    assert(potential_owner.try(:answerable?), "resource is not answerable")

    potential_owner
  end
end
