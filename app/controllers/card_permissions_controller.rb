# :nodoc:
class CardPermissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    card = Card.find(safe_params[:filter_by_card_id])
    requires_user_can(:edit, card)

    action = safe_params[:permission_action].to_s

    # Limit the actions that can be managed by this controller
    assert(action == 'edit' || action == 'view', "Bad action")

    check_roles(card)

    respond_with CardPermissions.add_roles(card, action, roles),
                 serializer: CardPermissionSerializer
  end

  def show
    permission = Permission.find(params[:id])
    card = Card.find(permission.filter_by_card_id)
    requires_user_can(:edit, card)

    respond_with permission, serializer: CardPermissionSerializer
  end

  def update
    permission = Permission.find(params[:id])
    card = Card.find(permission.filter_by_card_id)
    requires_user_can(:edit, card)
    check_roles(card)
    task_permission = CardPermissions.set_roles(
      card, Permission.find(params[:id]).action,
      roles
    )
    respond_with task_permission, serializer: CardPermissionSerializer
  end

  private

  def safe_params
    @safe_params ||= params.require(:card_permission).permit(
      :filter_by_card_id, :permission_action, role_ids: []
    )
  end

  def roles
    @roles ||= Role.where(id: safe_params[:role_ids]).includes(:journal)
  end

  def check_roles(card)
    roles.each do |role|
      assert(
        role.journal == card.journal,
        "Cannot add a role to a permission that filters on a card not in the \
same journal as the permission."
      )
    end
  end
end
