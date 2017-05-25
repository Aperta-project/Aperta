# This module contains custom cast types that don't fit within
# the base stuff we get from ActiveRecord.  We use this
# see https://tinyurl.com/zurd3ek for details.
module CustomCastTypes
  # This returns a sanitized HTML string appropriate for
  # client-side consumption
  class HtmlString < ActiveRecord::Type::String
    include ActionView::Helpers::SanitizeHelper

    def cast_value(value)
      scrubber = HtmlScrubber.new
      sanitize(value, scrubber: scrubber)
    end
  end
end
