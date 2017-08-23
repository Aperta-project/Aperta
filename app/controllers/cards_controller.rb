# CARD_CONFIG
# This is a part of the card config initiative. If you're not working on
# card config, you can probably ignore this.
class CardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from XmlCardDocument::XmlValidationError,
              with: :render_xml_validation_errors

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

  def show
    requires_user_can(:view, card)
    respond_with card
  end

  # Updates the card from the given xml data.  A 422 likely means that
  # the xml doesn't conform to the schema in config/card.rng (which is
  # generated from config/card.rnc)
  def update
    requires_user_can(:edit, card)
    card.update(card_params)
    respond_with card
  end

  def destroy
    requires_user_can(:edit, card)

    respond_with card.destroy
  end

  def publish
    requires_user_can(:edit, card)

    history_entry = params[:historyEntry]

    card.publish!(history_entry, current_user)

    # respond with the latest card version so that the client can immediately
    # show the new history entry if needed. The card itself is manually reloaded
    # by the client after it receives the 'publish' response
    render json: card.latest_card_version
  end

  def archive
    requires_user_can(:edit, card)
    card.archive!

    render json: card
  end

  def revert
    requires_user_can(:edit, card)
    card.revert!

    render json: card
  end

  def render_xml_validation_errors(ex)
    render status: 422, json: { errors: { xml: ex.errors } }
  end

  def create
    journal = Journal.find(card_params[:journal_id])
    requires_user_can(:create_card, journal)

    respond_with Card.create_initial_draft!(card_params)
  end

  private

  def card
    @card ||= Card.find(params[:id])
  end

  def card_params
    keys = %i[name journal_id xml]
    params.require(:card).permit(*keys)
  end
end
