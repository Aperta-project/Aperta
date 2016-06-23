module Authorizations
  # Construct a query which finds users who are capable of doing an action
  # to a particular object.
  #
  # BUT BEWARE! This doesn't take permission states into account. Don't expect
  # this to work as intended if you have a permission that specifies a specific
  # state.
  class ReverseQuery
    def initialize(permission:, target:)
      @action = permission.to_sym
      @target = target

      if target.is_a?(ActiveRecord::Base)
        @klass = target.class
      else
        fail NotImplementedError
      end
    end

    def all
      users_with_access_to(@target)
    end

    # return users who are assigned directly to target as well as users
    # who are assigned to a models which authorize target
    def users_with_access_to(target)
      users_assigned_directly_to(target)
        .concat(users_authorized_through_parents_of(target))
        .uniq
    end

    # return users who are assigned to parents of an object which authorizes
    # target
    def users_authorized_through_parents_of(target)
      models_which_authorize(target).map do |authorizing_model|
        users_with_access_to(authorizing_model) # recurse
      end.flatten
    end

    # return users who are assigned directly to assigned_to
    def users_assigned_directly_to(assigned_to)
      User.joins(assignments: :permissions)
        .where(assignments: { assigned_to: assigned_to })
        .where(permissions: { action: @action,
                              applies_to: @target.class.name }).all
    end

    # return models which authorize target_model
    def models_which_authorize(target_model)
      authorizations_on_target(target_model).map do |authorization|
        target_model.send(authorization.inverse_of_via)
      end.select(&:present?)
    end

    def authorizations_on_target(target)
      Authorizations.configuration.authorizations.select do |auth|
        auth.authorizes == target.class
      end
    end
  end
end
