# This controller is responsible for managing CardVersions.
#
# The primary purpose of a CardVersion is to be a container for multiple
# CardContent at a specific point in time.  An administrator may decide to add
# additional questions or perhaps change the layout of elements within a Card.
# Asking for a particular CardVersion will allow those changes to happen
# without automatically making those changes on its owner, such as Task.
#
class CardVersionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can(:view, card_version.card)
    respond_with card_version
  end

  private

  def card_version
    @card_version ||= CardVersion.find(params[:id])
  end
end
