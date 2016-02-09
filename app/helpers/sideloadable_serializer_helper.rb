# This helper method makes it easy to side load permissions (or other
# resources) into the JSON response.
#
# Usage:
#   side_load :example_method_to_side_load
#
#   # The key in the sideloaded JSON will match method name
#   def example_method_to_side_load
#      return {example_property: 'example_key'}
#   end
#
#  JSON Returned from serializer:
#  {example_method_to_side_load: {example_property: 'example_key'} }

module SideloadableSerializerHelper
  def self.included(base)
    base.extend ClassMethods
  end

  # Included class methods
  module ClassMethods
    def side_load(side_load_source)
      to_side_load(side_load_source)
    end

    def to_side_load(side_load_source = nil)
      @to_side_load ||= []
      if side_load_source
        @to_side_load << side_load_source
        return nil
      else
        return @to_side_load
      end
    end
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge(side_loader)
  end

  def side_loader
    side_loading = self.class.to_side_load
    result = {}
    side_loading.each do |method|
      result[method] = send(method).as_json
    end
    result
  end
end
