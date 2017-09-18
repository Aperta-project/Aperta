class Admin::JournalUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:manage_users, Journal)
    if params[:query].present?
      users = User.search_users(params[:query])
    elsif params[:journal_id].present?
      users = User.assigned_to_journal(params[:journal_id])
    else
      users = User.none
    end

    journal = Journal.find(params[:journal_id]) if params[:journal_id]
    respond_with users, each_serializer: AdminJournalUserSerializer, root: 'admin_journal_users', journal: journal
  end

  def update # Updates role
    if journal_user_params[:journal_id].present?
      requires_user_can(:administer, journal)

      assign_roles
    else
      requires_user_can(:administer, Journal)

      update_user_details
    end
    respond_with user, serializer: AdminJournalUserSerializer
  end

  private

  def assign_roles
    if journal_user_params[:modify_action] == 'add-role'
      user.assign_to!(assigned_to: journal,
                      role: journal_user_params[:journal_role_name])
    elsif journal_user_params[:modify_action] == 'remove-role'
      user.resign_from!(assigned_to: journal,
                        role: journal_user_params[:journal_role_name])
    end
  end

  def update_user_details
    user.update(journal_user_params.slice(:first_name, :last_name, :username))
  end

  def user
    @user ||= User.find(params[:id])
  end

  def journal
    @journal ||= Journal.find(journal_user_params[:journal_id])
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
