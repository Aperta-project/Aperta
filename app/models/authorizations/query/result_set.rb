require_dependency 'authorizations/query/serializable_result'

module Authorizations
  class Query

    # Authorizations::Query::ResultSet represents the results of running an
    # Authorizations::Query.
    class ResultSet
      delegate :each, :map, :length, to: :@object_permission_map

      def initialize
        @object_permission_map = Hash.new { |h, k| h[k] = {} }
      end

      # Add an object (e.g. ActiveRecord model instance) to this ResultSet
      # with an accompanying permission hash.
      def add_object(object, with_permissions: {})
        @object_permission_map[object].merge!(with_permissions) do |_k, v1, v2|
          { states: (v1[:states] + v2[:states]).uniq.sort }
        end
        self
      end

      # Add multiple objects (e.g. ActiveRecord model instances) to this \
      # ResultSet all with the accompanying permission hash.
      def add_objects(objects, with_permissions: {})
        objects.each do |object|
          add_object object, with_permissions: with_permissions
        end
        self
      end

      # Return all of the objects (e.g. ActiveRecord model instances) in this
      # ResultSet.
      def objects
        @object_permission_map.keys
      end

      def as_json
        serializable.as_json
      end

      # Retruns a collection of Authorizations::Query::Result objects that
      # can be serialized for client applications to consume.
      def serializable
        results = []
        each do |object, permissions|
          results << SerializableResult.new(object, permissions)
        end
        results
      end
    end
  end
end
