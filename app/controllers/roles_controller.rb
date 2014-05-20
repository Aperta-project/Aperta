class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!
  respond_to :json

  def create
    role = Role.create(role_params)
    respond_with role
  end

  def update
    role = Role.find(params[:id])
    role.update_attributes(role_params)
    respond_with role
  end

  def destroy
    role = Role.find(params[:id])
    role.destroy
    respond_with role
  end

  private

  def role_params
    params.require(:role).permit(:name, :admin, :editor, :reviewer, :journal_id,
      :can_administer_journal, :can_view_assigned_manuscript_managers, :can_view_all_manuscript_managers)
  end
end
