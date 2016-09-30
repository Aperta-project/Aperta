module Authorizations
  class Query
    # Authorization queries need to be able to return
    #   1. Any type of object that an be authorized
    #   2. The permissions associated with that object
    # This class accomplishes that
    class ResultSet
      def initialize
        @object_permission_map = Hash.new { |h, k| h[k] = {} }
      end

      def add_object(object, with_permissions: {})
        @object_permission_map[object].merge!(with_permissions) do |_k, v1, v2|
          { states: (v1[:states] + v2[:states]).uniq.sort }
        end
      end

      def add_objects(objects, with_permissions: {})
        objects.each do |object|
          add_object object, with_permissions: with_permissions
        end
      end

      def objects
        @object_permission_map.keys
      end

      delegate :each, :map, :length, to: :@object_permission_map

      def as_json
        serializable.as_json
      end

      def serializable
        results = []
        each do |object, permissions|
          item = PermissionResult.new(
            object: { id: object.id, type: object.class.sti_name },
            permissions: permissions,
            id: "#{Emberize.class_name(object.class)}+#{object.id}"
          )

          results.push item
        end
        results
      end
    end
  end
end
