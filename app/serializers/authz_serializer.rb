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

class AuthzSerializer < ActiveModel::Serializer
  def attributes
    # Skip authz checking for the first call only. Assume that authz happened at
    # the controller level. This is an optimization only.
    options[:inside_association] ||= false
    if !options[:inside_association]
      super
    elsif can_view?
      super
    else
      unauthorized_result
    end
  end

  def include_associations!
    orig_val = options[:inside_association]
    options[:inside_association] = true
    super
  ensure
    options[:inside_association] = orig_val
  end

  private

  def can_view?
    # Assume that if there is no scope, this is accessible
    return true if scope.nil?
    object.user_can_view?(scope)
  end

  def unauthorized_result
    { id: object.id }
  end
end
