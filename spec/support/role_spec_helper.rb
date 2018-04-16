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

class RoleSpecHelper
  def self.create_role(name, context, participates_in: [], &blk)
    new(name, context, participates_in: participates_in, &blk).role
  end

  attr_reader :role

  def initialize(name, context, participates_in: [], &blk)
    @name = name

    attrs = participates_in.each_with_object({}) do |klass, hsh|
      column = "participates_in_#{klass.name.underscore.downcase.pluralize}"
      hsh[column] = true
    end

    @role = FactoryGirl.create(:role, attrs.merge(name: name))
    instance_exec(context, &blk) if blk
    self
  end

  def has_permission(action:, applies_to:, states: ['*'], **kwargs)
    permissions = Permission.includes(:states).where(
      action: action,
      applies_to: applies_to,
      **kwargs
    ).select do |permission|
      permission.states.map(&:name).map(&:to_s).sort == states.map(&:to_s).sort
    end
    if permissions.empty?
      raise <<-MSG.strip_heredoc
        Permission not found for action=#{action} applies_to=#{applies_to}
        with the following states: #{states.inspect}

        The calling spec may not be defining the permission. Make sure you
        declare the permission for the action, applies_to, and all of the states
        that you're intending to give a role. E.g.:

          permission(
            action: '#{action}',
            applies_to: #{applies_to},
            states: #{states.inspect}
          )
      MSG
    end
    @role.permissions |= permissions
    @role
  end
end
