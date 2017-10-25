class ContentAttribute < ActiveRecord::Base
  include XmlSerializable
  include Attribute

  is_attribute_of :card_content, inverse_of: :content_attributes
end
