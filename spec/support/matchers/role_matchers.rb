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

# Simple matcher to test if a user has a role assigned.
RSpec::Matchers.define :have_role do |expected_role_name, thing|
  match do |user|
    if expected_role_name.is_a? String
      # Simple role matching
      user.roles.where(name: expected_role_name).present?
    else
      # Passed in actual role, check with assigned_to
      user.assignments.where(role: expected_role_name, assigned_to: thing).present?
    end
  end

  failure_message do
    thing_str = thing.present? ? " (on #{thing})" : ""
    "Expected user to have the role, '#{expected_role_name}'#{thing_str}"
  end

  failure_message_when_negated do
    thing_str = thing.present? ? " (on #{thing})" : ""
    "Expected user to not have the role, '#{expected_role_name}'#{thing_str}"
  end
end

RSpec::Matchers.define :be_able_to do |permission, *things|
  match do |user|
    things.map { |thing| user.can?(permission, thing) }.all?
  end

  failure_message do
    retval = ""
    things.map do |thing|
      retval << "Expected user to be able to #{permission} #{thing}.\n" unless user.can?(permission, thing)
    end
    retval
  end

  failure_message_when_negated do
    retval = ""
    things.map do |thing|
      retval << "Expected user NOT to be able to #{permission} #{thing}.\n" if user.can?(permission, thing)
    end
    retval
  end
end
