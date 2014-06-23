class Admin::JournalUsersController < ApplicationController
  respond_to :json

  def index
    users = User.search_users(params[:query] || "")
    respond_with users, each_serializer: AdminJournalUserSerializer, root: 'admin_journal_users'
  end

  def update
    user = User.find(params[:id])
    user.update(journal_user_params)
    respond_with user, serializer: AdminJournalUserSerializer
  end

  def journal_user_params
    params.require(:admin_journal_user).permit(:first_name, :last_name, :username)
  end
end
