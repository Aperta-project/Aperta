class Permission < ActiveRecord::Base
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
