# :nodoc:
class CardPermissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:edit, Card.find(safe_params[:filter_by_card_id]))

    action = safe_params[:permission_action].to_s
    # Limit the actions that can be managed by this controller
    assert(action == 'edit' || action == 'view', "Bad action")

    # Override default @task_permission, @card_permission
    @task_permission = Permission.ensure_exists(
      action,
      applies_to: 'Task',
      filter_by_card_id: safe_params[:filter_by_card_id]
    )

    @card_permission = Permission.ensure_exists(
      'view',
      applies_to: 'CardVersion',
      filter_by_card_id: safe_params[:filter_by_card_id]
    )

    # When creating a new permission, append the roles if the permission already
    # existing and the client did not know about it.
    task_permission.roles.concat(*(roles - task_permission.roles))
    card_permission.roles.concat(*(roles - card_permission.roles))
    task_permission.save!
    card_permission.save!

    respond_with task_permission, serializer: CardPermissionSerializer
  end

  def destroy
    requires_user_can(:edit, card)

    task_permission.destroy
    card_permission.destroy if task_permission.action == 'view'
    respond_with :empty, serializer: CardPermissionSerializer
  end

  def show
    requires_user_can(:edit, card)

    respond_with task_permission, serializer: CardPermissionSerializer
  end

  def update
    requires_user_can(:edit, card)

    # The only valid thing to do when updating a permission is to change the
    # roles attached to it.
    task_permission.roles.replace(roles)
    card_permission.roles.replace(roles)
    task_permission.save!
    card_permission.save!

    respond_with task_permission, serializer: CardPermissionSerializer
  end

  private

  def safe_params
    @safe_params ||= params.require(:card_permission).permit(
      :filter_by_card_id, :permission_action, role_ids: []
    )
  end

  def card
    @card ||= Card.find(task_permission.filter_by_card_id)
  end

  def task_permission
    @task_permission ||= Permission.find(params[:id])
  end

  def card_permission
    @card_permission ||= Permission.where(
      applies_to: 'CardVersion',
      action: 'view',
      filter_by_card_id: task_permission.filter_by_card_id
    ).first
  end

  def roles
    @roles ||= Role.where(id: safe_params[:role_ids])
                 .includes(:journal).tap do |roles|
      roles.each do |role|
        assert(
          role.journal == card.journal,
          "Cannot add a role to a permission that filters on a card not in the \
same journal as the permission."
        )
      end
    end
  end
end
