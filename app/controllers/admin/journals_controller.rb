class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    respond_with current_user.administered_journals, each_serializer: AdminJournalSerializer, root: 'admin_journals'
  end
end
