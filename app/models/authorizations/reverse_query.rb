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
        raise NotImplementedError
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
      query = User.joins(assignments: :permissions)
        .where(assignments: { assigned_to: assigned_to })
        .where(permissions: { action: @action,
                              applies_to: [@target.class.name, @target.class.base_class.name] })
      query = query.where(permissions: { filter_by_card_id: @target.card_version.card_id }) if @target.is_a?(Task)
      query.all
    end

    # return models which authorize target_model
    def models_which_authorize(target_model)
      authorizations_on_target(target_model).map do |authorization|
        if authorization.inverse_of_via
          target_model.send(authorization.inverse_of_via)
        end
      end.select(&:present?)
    end

    def authorizations_on_target(target)
      Authorizations.configuration.authorizations.select do |auth|
        auth.authorizes == target.class.try(:base_class)
      end
    end
  end
end
