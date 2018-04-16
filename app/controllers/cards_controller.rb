# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
    card.update!(card_params)
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
    keys = %i[name journal_id xml card_task_type_id]
    params.require(:card).permit(*keys)
  end
end
