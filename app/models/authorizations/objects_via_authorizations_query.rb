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

  # ObjectsViaAuthorizationsQuery represents the query responsible for finding
  # all objects through a given set of authorization pathways.
  #
  # Running an instance of this query generates a set of UNION'd queries
  # responsible for finding the @klass in question based on the provided
  # Authorizations::Authorization paths.
  #
  class ObjectsViaAuthorizationsQuery
    include QueryHelpers
    attr_reader :auth_configs, :klass, :target, :assignments_table

    # == Constructor Arguments
    # * target: the ActiveRecord::Relation that we want to query objects from
    # * klass: the type/class that is being queried against
    # * auth_configs: the collection of Authorization(s) to JOIN against
    # * assignments_table: the Arel::Table instance to be used when JOINing \
    #     and filtering against Assignment(s)
    def initialize(target:, klass:, auth_configs:, assignments_table:)
      @auth_configs = auth_configs
      @klass = klass
      @target = target
      @assignments_table = assignments_table
    end

    # This query returns more than the permissible objects.
    def to_arel
      auth_path_queries = auth_configs.map do |auth_config|
        construct_query_for_auth_config(auth_config)
      end

      union(auth_path_queries.map(&:to_arel))
    end

    def to_sql
      to_arel.to_sql
    end

    private

    # This returns a query object built specifically for the given
    # Authorizations::Authorization object.
    def construct_query_for_auth_config(auth_config)
      reflection = auth_config.reflection
      args = {
        target: target,
        auth_config: auth_config,
        assignments_table: assignments_table,
        klass: klass
      }

      if auth_config.assignment_to <=> @klass
        ObjectsAuthorizedViaSelfQuery.new(args)

      elsif reflection.nil?
        raise MissingAssociationForAuthConfiguration, <<-ERROR.strip_heredoc
          Expected to find #{auth_config.via.inspect} association defined on
          #{auth_config.assignment_to}, but did not. This was because the following
          Authorizations::Configuration was configured:

          #{auth_config.inspect}
        ERROR

      elsif reflection.respond_to?(:through_options)
        ObjectsAuthorizedViaThroughAssociationQuery.new(args)

      elsif reflection.collection? || reflection.has_one?
        ObjectsAuthorizedViaCollectionQuery.new(args)

      elsif reflection.belongs_to?
        ObjectsAuthorizedViaBelongsToQuery.new(args)

      else
        raise "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
      end
    end
  end
end
