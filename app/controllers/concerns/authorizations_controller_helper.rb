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

# Controller helper for roles and permissions
# ex: requires_user_can :withdraw, paper
module AuthorizationsControllerHelper
  extend ActiveSupport::Concern

  # Error when user is unauthorized to perform action. Raises HTTP 403.
  class AuthorizationError < StandardError; end

  # Error when user is unauthorized to perform action or action not found. Raises HTTP 404.
  # This error has the advantage of not revealing to the user the existence of certain resources.
  class NotFoundError < StandardError; end

  included do
    rescue_from AuthorizationError, with: :unauthorized
    rescue_from NotFoundError, with: :render_not_found
  end

  def requires_that(not_found: false)
    return if yield
    raise NotFoundError if not_found
    raise AuthorizationError
  end

  def requires_user_can(permission, object, not_found: false)
    requires_that(not_found: not_found) do
      current_user.can?(permission, object)
    end
  end

  def requires_user_can_view(object, not_found: false)
    requires_that(not_found: not_found) do
      object.user_can_view?(current_user)
    end
  end

  private

  def unauthorized
    head :forbidden
  end

  def render_not_found
    render text: "Sorry, we're unable to find the page you requested.", status: 404
  end
end
