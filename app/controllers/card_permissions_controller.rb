# :nodoc:
class CardPermissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:edit, card)

    action = safe_params[:permission_action].to_s
    # Limit the actions that can be managed by this controller
    assert(action == 'edit' || action == 'view', "Bad action")

    perm = Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: card.id
    )
    perm.roles += Role.where(id: safe_params[:role_ids])
    perm.save!
    respond_with perm, serializer: CardPermissionSerializer
  end

  def destroy
    requires_user_can(:edit, card)

    respond_with permission.destroy,
                 serializer: CardPermissionSerializer
  end

  def index
    requires_user_can(:edit, card)

    respond_with Permission.where(filter_by_card_id: card.id),
                 each_serializer: CardPermissionSerializer
  end

  def show
    requires_user_can(:edit, card)

    respond_with permission,
                 serializer: CardPermissionSerializer
  end

  def update
    requires_user_can(:edit, card)

    # The only valid thing to do when updating a permission is to change the
    # roles attached to it.
    permission.roles += Role.where(id: safe_params[:role_ids])
    permission.save!
    respond_with permission, serializer: CardPermissionSerializer
  end

  private

  def safe_params
    @safe_params ||= params.permit(:permission_action, role_ids: [])
  end

  def card
    @card ||= Card.find(params[:card_id])
  end

  def permission
    @permission ||= Permission.find(params[:id]).tap do |permission|
      assert(permission.filter_by_card_id == card.id,
             "Permission/card id mismatch")
    end
  end
end
