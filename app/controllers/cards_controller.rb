# CARD_CONFIG
# This is a part of the card config initiative. If you're not working on
# card config, you can probably ignore this.
class CardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from Nokogiri::XML::SyntaxError,
              with: :render_xml_syntax_error

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
    card.xml = params[:card][:xml] if params[:card][:xml].present?
    card.update!(card_params)

    respond_with card
  end

  def render_xml_syntax_error(ex)
    msg = "line #{ex.line} column #{ex.column}: #{ex.message}"
    render status: 422,
           json: { errors: { xml: msg } }
  end

  def create
    journal = Journal.find(card_params[:journal_id])
    requires_user_can(:create_card, journal)

    respond_with Card.create_new!(card_params)
  end

  private

  def card
    @card ||= Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(
      :name,
      :journal_id
    )
  end
end
