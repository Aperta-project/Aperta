module PolyArraySerializer
  extend ActiveSupport::Concern

  module ClassMethods
    def each_serializer=(serializer)
      @each_serializer = serializer
    end

    def each_serializer
      @each_serializer
    end
  end

  included do
    def initialize(object, options = {})
      options[:each_serializer] = self.class.each_serializer
      options[:root] = nil
      super(object, options)
    end

    def as_json(*args)
      arr = super
      retval = {}
      arr.each do |hsh|
        hsh.each do |key, val|
          retval[key] ||= []
          retval[key] << val
        end
      end
      retval
    end

    def _serializable_array
      @object.map do |item|
        if @options.key? :each_serializer
          serializer = @options[:each_serializer]
        elsif item.respond_to?(:active_model_serializer)
          serializer = item.active_model_serializer
        end

        serializable = serializer ? serializer.new(item, @options) : DefaultSerializer.new(item, @options.merge(root: false))

        val = if serializable.respond_to?(:serializable_hash)
                serializable.serializable_hash
              else
                serializable.as_json
              end
        { serializable.root_name.to_s.pluralize => val }
      end
    end
  end
end
