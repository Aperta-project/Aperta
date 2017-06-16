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
    # If called from the author's manuscript sidebar, this request won't come
    # with a task ID. Instead we need to verify that the user owns any task
    # assigned to this card version.
    task = Task.joins(:paper).find_by(
      papers: { user_id: current_user.id },
      tasks: { card_version_id: params[:id] }
    )
    if task.present?
      requires_user_can(:view, task)
    else
      requires_user_can(:view, card_version.card)
    end
    respond_with card_version
  end

  private

  def card_version
    @card_version ||= CardVersion.find(params[:id])
  end
end
