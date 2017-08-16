# This module contains custom cast types that don't fit within
# the base stuff we get from ActiveRecord.
module CustomCastTypes
  # This returns a sanitized HTML string to be stored in the database.
  class HtmlString < ActiveRecord::Type::String
    include ActionView::Helpers::SanitizeHelper

    def type_cast_for_database(value)
      scrubber = HtmlScrubber.new
      sanitize(value, scrubber: scrubber)
    end
  end
end
