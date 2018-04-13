# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# :nodoc:
class CardPermissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  CARD_ACTIONS = %w[view edit view_discussion_footer edit_discussion_footer be_assigned assign_others view_participants manage_participant].freeze

  def create
    card = Card.find(safe_params[:filter_by_card_id])
    requires_user_can(:edit, card)

    action = safe_params[:permission_action].to_s
    # Limit the actions that can be managed by this controller
    assert(CARD_ACTIONS.include?(action), "Bad card permission action")

    check_roles(card)

    render status: :created,
           json: CardPermissions.add_roles(card, action, roles),
           each_serializer: CardPermissionSerializer
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
    task_permissions = CardPermissions.set_roles(
      card,
      permission.action,
      roles
    )
    render status: :ok,
           json: task_permissions,
           each_serializer: CardPermissionSerializer
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
