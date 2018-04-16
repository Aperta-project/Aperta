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

module AuthorizationSpecHelper
  extend ActiveSupport::Concern

  class_methods do
    def permissions(label=nil, &blk)
      let_name = ['permissions', label].compact.join('_')
      let!(let_name) do
        PermissionSpecHelper.create_permissions(label, self, &blk)
      end
    end

    def permission(action:, applies_to:, states:, **kwargs)
      let_name = ['permission', action, applies_to].compact.join('_')
      let!(let_name) do
        PermissionSpecHelper.create_permission(let_name, self, action: action, applies_to: applies_to, states: states, **kwargs)
      end
    end

    def role(name, participates_in: [], &blk)
      let_name = ['role', name].compact.join('_').gsub(/\s+/, '_')
      let!(let_name) do
        RoleSpecHelper.create_role(name, self, participates_in: participates_in, &blk)
      end
    end
  end

  def assign_user(user, to:, with_role:)
    user.assignments.where(assigned_to: to, role: with_role).first_or_create
  end

  def count_queries(message, &blk)
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_key, _started, _finished, _unique_id, _data|
      queries += 1
    end
    yield blk
    puts "#{message} took #{queries} queries"
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
end
