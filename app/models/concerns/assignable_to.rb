module AssignableTo
  extend ActiveSupport::Concern

  included do
    scope :assignments_for, -> (user:, role:) do
      joins(:assignments).where(
        assignments: {
          assigned_to_type: name,
          role_id: role,
          user_id: user
        }
      )
    end
  end
end
