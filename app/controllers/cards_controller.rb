# CARD_CONFIG
# This is a part of the card config initiative. If you're not working on
# card config, you can probably ignore this.
class CardsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    journal_ids = current_user.filter_authorized(
      :administer,
      Journal,
      participations_only: false
    ).objects.map(&:id)

    if params['journal_id']
      journal_ids = journal_ids.select { |j| j == params['journal_id'].to_i }
    end

    respond_with JournalTaskType.where(journal_id: journal_ids)
  end
end
