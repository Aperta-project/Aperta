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

  # ObjectsAuthorizedViaCollectionQuery represents the query responsible for
  # finding all authorized objects through a has_many or has_one associations,
  # e.g.:
  #
  #    Authorizations::Authorization.new(
  #      assignment_to: Journal,
  #      authorizes: Paper,
  #      via: :papers
  #    )
  #
  # In the above authorization Journal has a has_many :papers association
  # for accessing its Paper(s). It only knows its a has_many association by
  # looking at up Task.reflections['paper'] definition.
  #
  # This works the same way for has_one :associations.
  #
  # == Columns returned
  #
  # Running this query will return the following columns:
  #
  #   * <klass.table_name>.id AS id
  #   * <assignments_table>.role_id AS role_id
  #   * <assignments_table>.permission_id AS permission_table
  #
  # The < and > brackets are used above because the table references are
  # dynamic. See the corresponding constructor arguments for more information.
  class ObjectsAuthorizedViaCollectionQuery
    include QueryHelpers

    attr_reader :auth_config, :assignments_table, :common_query, :target

    # == Constructor Arguments
    # * assignments_table: the Arel::Table reference representing the \
    #     assignments table to use for this query
    # * auth_config: the Authorization(s) path to JOIN against
    # * klass: the type/class that is being queried against
    # * target: the ActiveRecord::Relation being queried against
    def initialize(auth_config:, target:, assignments_table:, klass:)
      @auth_config = auth_config
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @target = target
    end

    def to_arel
      query = common_query.to_arel

      query.outer_join(common_query.join_table).on(
        common_query.join_table.primary_key.eq(assignments_table[:assigned_to_id]).and(
          assignments_table[:assigned_to_type].eq(common_query.assigned_to_klass.base_class.name)))
        .outer_join(common_query.target_table).on(
          common_query.target_table[auth_config.reflection.foreign_key].eq(common_query.join_table.primary_key))

      common_query.add_column_condition(
        query: query,
        column: common_query.join_table.primary_key,
        values: @target.where_values_hash[auth_config.reflection.foreign_key]
      )

      common_query.add_permission_state_check(query)
      common_query.add_filter_by_check(query)
    end

    def to_sql
      to_arel.to_sql
    end
  end
end
