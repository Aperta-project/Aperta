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

# Provides an additional layer of abstraction about the core permissions system
# to check if a user can view this thing. Perhaps at some point this will not be
# necessary, but as long as we have move complicated checks to see if a user can
# view something, this helps to make it clearer.
#
# This should be used by both serializers and controllers.

module ViewableModel
  extend ActiveSupport::Concern

  # Returns true if the user should be able to view this model. Override for
  # more complicated behavior.
  def user_can_view?(check_user)
    check_user.can?(:view, self)
  end

  class_methods do
    def delegate_view_permission_to(method)
      define_method "user_can_view?" do |check_user|
        send(method).user_can_view?(check_user)
      end
    end
  end
end
