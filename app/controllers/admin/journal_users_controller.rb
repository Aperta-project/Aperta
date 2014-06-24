class Admin::JournalUsersController < ApplicationController
  respond_to :json

  def index
    @users = User.search_users(params[:query])
    respond_with @users, each_serializer: AdminJournalUserSerializer, root: 'admin_journal_users'
  end
end
