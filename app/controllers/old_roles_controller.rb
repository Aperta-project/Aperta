class OldRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: :index
  respond_to :json

  def index
    journal = Journal.find(params[:journal_id])
    authorize_action! journal: journal

    render json: journal.old_roles
  end

  def show
    respond_with OldRole.find(params[:id])
  end

  def create
    old_role.save
    respond_with old_role
  end

  def update
    old_role.update(role_params)
    render json: old_role
  end

  def destroy
    old_role.destroy
    respond_with old_role
  end

  private

  def old_role
    @old_role ||=
      if params[:id]
        OldRole.find(params[:id])
      else
        OldRole.new(role_params)
      end
  end

  def journal
    if params[:old_role] && role_params[:journal_id]
      Journal.find(role_params[:journal_id])
    else
      old_role.journal
    end
  end

  def enforce_policy
    authorize_action!(journal: journal)
  end

  def role_params
    params.require(:old_role).permit(:name, :admin, :editor, :reviewer, :journal_id,
      :can_administer_journal, :can_view_assigned_manuscript_managers, :can_view_all_manuscript_managers)
  end
end
