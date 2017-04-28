# :nodoc:
class CardPermissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:edit, Card.find(safe_params[:card_id]))

    action = safe_params[:permission_action].to_s
    # Limit the actions that can be managed by this controller
    assert(action == 'edit' || action == 'view', "Bad action")

    # Override default @permission
    @permission = Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: safe_params[:card_id]
    )

    update_roles

    respond_with permission, serializer: CardPermissionSerializer
  end

  def destroy
    requires_user_can(:edit, card)

    respond_with permission.destroy, serializer: CardPermissionSerializer
  end

  def show
    requires_user_can(:edit, card)

    respond_with permission, serializer: CardPermissionSerializer
  end

  def update
    requires_user_can(:edit, card)

    # The only valid thing to do when updating a permission is to change the
    # roles attached to it.
    update_roles

    respond_with permission, serializer: CardPermissionSerializer
  end

  private

  def update_roles
    roles = Role.where(id: safe_params[:role_ids])
    roles.each do |role|
      assert(
        role.journal == card.journal,
        "Cannot add a role to a permission that filters on a card not in the \
same journal as the permission."
      )
    end
    permission.roles += roles
    permission.save!
  end

  def safe_params
    @safe_params ||= params.require(:card_permission).permit(
      :card_id, :permission_action, role_ids: []
    )
  end

  def card
    @card ||= Card.find(permission.filter_by_card_id)
  end

  def permission
    @permission ||= Permission.find(params[:id])
  end
end
