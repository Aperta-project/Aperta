class Admin::JournalUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:administer, Journal)
    users = User.search_users(query: params[:query], assigned_users_in_journal_id: params[:journal_id])
    journal = Journal.find(params[:journal_id]) if params[:journal_id]
    respond_with users, each_serializer: AdminJournalUserSerializer, root: 'admin_journal_users', journal: journal
  end

  def update # Updates role
    journal = Journal.find(journal_user_params[:journal_id])
    requires_user_can(:administer, journal)
    user = User.find(params[:id])
    if journal_user_params[:modify_action] == 'add-role'
      user.assign_to!(assigned_to: journal,
                      role: journal_user_params[:journal_role_name])
    elsif journal_user_params[:modify_action] == 'remove-role'
      user.resign_from!(assigned_to: journal,
                        role: journal_user_params[:journal_role_name])
    end
    respond_with user, serializer: AdminJournalUserSerializer
  end

  def journal_user_params
    params.require(:admin_journal_user)
      .permit(:first_name,
        :last_name,
        :username,
        :journal_id,
        :journal_role_name,
        :modify_action)
  end
end
