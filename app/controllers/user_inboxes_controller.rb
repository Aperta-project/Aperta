# used by client when an event notification has been 'dismissed'
#
class UserInboxesController < ApplicationController
  before_action :authenticate_user!

  def destroy
    Notifications::UserInbox.new(current_user.id).remove(params[:id])
    head :no_content
  end
end
