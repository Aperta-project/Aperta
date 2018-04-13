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
  class ObjectsPermissibleByRequiredPermissionsQuery
    include QueryHelpers

    attr_reader :assignments_table, :auth_config, :common_query,
      :klass, :objects_query, :target

    def initialize(klass:, assignments_table:, objects_query:)
      @klass = klass
      @assignments_table = assignments_table
      @objects_query = objects_query
    end

    def to_arel
      query = add_permissions_column_to_assignments
      add_permission_states(query)
      query.group(table[:results][:id])
    end

    def to_sql
      to_arel.to_sql
    end

    private

    def permission_actions_column
      Arel.sql("string_agg(distinct(concat(permissions.action::text, ':', permission_states.name::text)), ', ') AS permission_actions")
    end

    def add_permissions_column_to_assignments
      Arel::SelectManager.new(klass.arel_table.engine).
        with(assignments_table).
        project(
          table[:results][:id],
          permission_actions_column
        ).from(Arel.sql('(' + objects_query.to_sql + ')')
                 .as(table[:results].table_name))
    end

    def add_permission_states(query)
      query.join(table[:permissions]).on(
        table[:permissions][:id].eq(table[:results][:permission_id])
      ).join(table[:permission_states_permissions]).on(
        table[:permission_states_permissions][:permission_id].eq(table[:permissions][:id])
      ).join(table[:permission_states]).on(
        table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
      )
    end
  end
end
