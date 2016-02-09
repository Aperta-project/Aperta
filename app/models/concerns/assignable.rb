# Assignable is a module for assignment-related helper methods.
# See inner modules for more information.
module Assignable
  # Assignable::Model is a helper module to be included on models that a user
  # could be assigned to.
  #
  # == Examples
  #
  #    class Paper < ActiveRecord::Base
  #       include Assignable::Model
  #    end
  #
  #    Paper.assignments_for(user: tyler, role: Role.the_creator)
  #
  module Model
    extend ActiveSupport::Concern

    included do
      scope :assignments_for, lambda { |user:, role:|
        joins(:assignments).where(
          assignments: {
            assigned_to_type: name,
            role_id: role,
            user_id: user
          }
        )
      }
    end
  end

  # Assignable::User is a helper module to be included on the User model
  # for looking up things the user is assigned to.
  #
  # == Examples
  #
  #    class User < ActiveRecord::Base
  #       include Assignable::User
  #    end
  #
  #    User.assigned_to(Paper.first, role: Role.creator)
  #
  module User
    extend ActiveSupport::Concern

    included do
      scope :assigned_to, lambda { |resource, role:|
        joins(:assignments).where(
          assignments: {
            assigned_to: resource,
            role_id: role
          }
        )
      }
    end
  end
end
