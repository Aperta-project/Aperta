module Authorizations
  # Used to serialize Authorization::Query::ResultSets
  class PermissionResult
    attr_accessor :object, :permissions, :id
    include ActiveModel::SerializerSupport

    def initialize(object:, permissions:, id:)
      @object = object
      @permissions = permissions
      @id = id
    end
  end
end
