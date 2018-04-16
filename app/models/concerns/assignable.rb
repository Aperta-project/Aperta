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
