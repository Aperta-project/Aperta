# CARD_CONFIG
# This is a part of the card config initiative. If you're not working on
# card config, you can probably ignore this.
class CardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    respond_with owner_klass.find(params[:owner_id]).card
  end

  # Although this is the 'index' action, it's really only exists to find a
  # single card by its name.  The index route maps more nicely to Ember Data's
  # expectation for `queryRecord`.  As soon as multiple 'versions' of cards
  # exist this method will have to change to either find the latest version for
  # a given name or to find the correct Card instance for a given task
  def query_name
    respond_with Card.find_by(name: params[:name])
  end

  def index
    journal_ids = current_user.filter_authorized(
      :administer,
      Journal,
      participations_only: false
    ).objects.map(&:id)

    if params[:journal_id]
      journal_ids = journal_ids.select { |j| j == params[:journal_id].to_i }
    end

    respond_with Card.where(journal_id: journal_ids)
  end

  private

  def owner_klass
    potential_owner = params[:owner_type].classify.constantize
    assert(potential_owner.try(:answerable?), "resource is not answerable")

    potential_owner
  end
end
