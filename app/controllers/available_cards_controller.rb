# This controller is responsible for returning all custom Cards
# that are available on a particular Paper's Journal.
#
# This is useful on the paper workflow page where it is necessary
# to ask, "what are all the custom cards available to be added
# to this particular paper's workflow?"  These tasks may or may
# not have been added to the Paper when it was created.
#
# In addition, make sure that the user has the proper permissions
# to receive this data.  Permissions are checked against the Paper
# even though the resources returned are part of the Journal.
#
class AvailableCardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:manage_workflow, paper)
    respond_with paper.journal.cards, root: "cards"
  end

  private

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id])
  end
end
