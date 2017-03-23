require 'builder'

# Helper methods for xml serialization
module XmlSerializable
  extend ActiveSupport::Concern

  included do
    def setup_builder(options)
      options[:indent] ||= 2
      options[:builder] ||= ::Builder::XmlMarkup.new(indent: options[:indent])
      options[:builder].instruct! unless options[:skip_instruct]
      options[:builder]
    end
  end
end
