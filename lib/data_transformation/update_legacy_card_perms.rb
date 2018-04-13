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

module DataTransformation
  # Adds missing participant permissions to legacy cards
  class UpdateLegacyCardPerms < Base
    PARTICIPANT_PERMISSIONS = ['view_participants', 'manage_participant'].freeze

    def transform
      update_participant_permissions
      run_assertions
    end

    def update_participant_permissions
      Card.joins(:journal).includes(:journal).all.each do |card|
        default_permissions = CustomCard::DefaultCardPermissions.new(card.journal)
        card_key = card.name.delete(' ').underscore # reverse titleize
        next unless default_permissions.permissions[card_key]
        default_permissions.apply(card_key) do |action, roles|
          CardPermissions.set_roles(card, action, roles) if PARTICIPANT_PERMISSIONS.include?(action)
        end
      end
    end

    def run_assertions
      permissions = Permission.includes(:roles).all
      default_permissions = CustomCard::DefaultCardPermissions.new({}) # journal doesn't matter here
      default_permissions.permissions.each do |card_key, role_permissions|
        Card.joins(:journal).where(name: card_key.titleize).each do |card|
          role_permissions.each do |role_name, actions|
            (actions & PARTICIPANT_PERMISSIONS).each do |action|
              has_permission = permissions_has_card_action_for_role?(permissions, card, action, role_name)
              assert(has_permission, "Failed to create new permission")
            end
          end
        end
      end
    end

    def permissions_has_card_action_for_role?(permissions, card, action, role_name)
      permissions.any? do |permission|
        permission.filter_by_card_id == card.id &&
          permission.action == action &&
          permission.roles.where(name: role_name).count
      end
    end
  end
end
