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

class Permission < ActiveRecord::Base
  include ViewableModel
  # The WILDCARD permission represents permission to all things.
  WILDCARD = '*'.freeze

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :states, class_name: 'PermissionState'

  validates(:filter_by_card_id, presence: true, if: -> { applies_to == CustomCardTask.to_s })

  def self.custom_card
    where.not(filter_by_card_id: nil)
  end

  def self.non_custom_card
    where(filter_by_card_id: nil)
  end

  def self.ensure_exists(
        action,
        applies_to:,
        role: nil,
        states: [Permission::WILDCARD],
        **kwargs
  )
    permission_states = PermissionState.from_strings(states)

    Permission.joins(:states).where(
      action: action,
      applies_to: applies_to.to_s,
      **kwargs
    ).group('permissions.id')
    .having(
      'ARRAY[?] = ARRAY_AGG(permission_states.id ORDER
         BY permission_states.id)',
      permission_states.map(&:id).sort
    ).first_or_create!.tap do |perm|
      perm.states = permission_states
      role.permissions = (role.permissions | [perm]) unless role.nil?
    end
  end
end
