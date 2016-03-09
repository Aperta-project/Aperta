# +PaperRoleUsersController+ is responsible for communicating eligible users for
# a given paper and role.
class PaperRoleEligibleUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:view_user_role_eligibility_on_paper, paper)
    role = Role.find_by!(id: params[:role_id], journal_id: paper.journal_id)
    eligible_users = EligibleUserService.eligible_users_for(
      paper: paper,
      role: role
    )
    render json: eligible_users, each_serializer: UserSerializer, root: 'users'
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end
end
