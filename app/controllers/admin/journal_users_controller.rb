class Admin::JournalUsersController < ApplicationController
  respond_to :json

  def index
    users = User.search_users(query: params[:query], assigned_users_in_journal_id: params[:journal_id])
    respond_with users, each_serializer: AdminJournalUserSerializer, root: 'admin_journal_users', journal: Journal.find(params[:journal_id])
  end

  def update
    user = User.find(params[:id])
    user.update(journal_user_params)
    respond_with user, serializer: AdminJournalUserSerializer
  end

  def reset
    user = User.find(params[:id])
    head :ok if user.send_reset_password_instructions
  end

  def journal_user_params
    params.require(:admin_journal_user).permit(:first_name, :last_name, :username)
  end
end
