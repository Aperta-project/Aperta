class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def show
    respond_with Role.find(params[:id])
  end

  def create
    role.save
    respond_with role
  end

  def update
    Role.transaction do
      role.assign_attributes(role_params)
      if role.can_view_flow_manager_changed?(from: false, to: true)
        RoleFlow.create_default_flows!(role)
      end
      role.save!
    end

    render json: role
  end

  def destroy
    role.destroy
    respond_with role
  end

  private

  def role
    @role ||=
      if params[:id]
        Role.find(params[:id])
      else
        Role.new(role_params)
      end
  end

  def journal
    if params[:role] && role_params[:journal_id]
      Journal.find(role_params[:journal_id])
    else
      role.journal
    end
  end

  def enforce_policy
    authorize_action!(journal: journal)
  end

  def role_params
    params.require(:role).permit(:name, :admin, :editor, :reviewer, :journal_id,
      :can_administer_journal, :can_view_assigned_manuscript_managers, :can_view_all_manuscript_managers, :can_view_flow_manager)
  end
end
