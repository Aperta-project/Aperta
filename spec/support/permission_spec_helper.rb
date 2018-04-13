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

class PermissionSpecHelper
  def self.create_permissions(label = nil, context, &blk)
    new(label, context, &blk).permissions
  end

  def self.create_permission(label, context, action:, applies_to:, states:, filter_by_card_id: nil, **kwargs)
    new(label, context).permission(action: action,
                                   applies_to: applies_to,
                                   states: states,
                                   filter_by_card_id: filter_by_card_id,
                                   **kwargs)
  end

  attr_reader :permissions

  def initialize(label, context, &blk)
    @label = label
    @permissions = []
    instance_exec(context, &blk) if blk
    self
  end

  def permission(action:, applies_to:, states: ['*'], filter_by_card_id: nil, **kwargs)
    states = states.map { |state_name| PermissionState.where(name: state_name).first_or_create! }
    perm = Permission.ensure_exists(action,
                                    applies_to: applies_to,
                                    states: states,
                                    filter_by_card_id: filter_by_card_id,
                                    **kwargs)
    @permissions.push perm
    perm
  end
end
