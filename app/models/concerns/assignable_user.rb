module AssignableUser
  extend ActiveSupport::Concern

  included do
    scope :assigned_to, -> (resource, role:) do
      joins(:assignments).where(
        assignments: {
          assigned_to: resource,
          role_id: role,
          user_id: user
        }
      )
    end
  end
end
