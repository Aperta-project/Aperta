class FilteredUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def users
    users = User.all.search do
      fulltext params[:query]
    end

    respond_with users.results, each_serializer: FilteredUserSerializer,
                                paper_id: params[:paper_id]
  end

  def editors
    journal = Journal.find(params[:journal_id])
    editor_ids = journal.editors.pluck(:id)
    editors = User.search do
      with(:id, editor_ids)
      fulltext params[:query]
    end
    respond_with editors.results, each_serializer: SelectableUserSerializer
  end

  def admins
    journal = Journal.find(params[:journal_id])
    admin_ids = journal.admins.pluck(:id)
    admins = User.search do
      with(:id, admin_ids)
      fulltext params[:query]
    end
    respond_with admins.results, each_serializer: SelectableUserSerializer
  end
end
