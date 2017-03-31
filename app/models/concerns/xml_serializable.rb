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

    # Dump text into an element. If the text contains & or < , wrap the content
    # in a CDATA section.
    def safe_dump_text(builder, tag, text)
      if text =~ /(<|&)/
        builder.tag!(tag) { builder.cdata! text }
      else
        builder.tag!(tag, text)
      end
    end
  end
end
