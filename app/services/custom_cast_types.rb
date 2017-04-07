# This module contains custom cast types that don't fit within
# the base stuff we get from ActiveRecord
module CustomCastTypes
  # This returns a sanitized HTML string appropriate for
  # client-side consumption
  class HtmlString < ActiveRecord::Type::String
    include ActionView::Helpers::SanitizeHelper

    def cast_value(value)
      # This should be replace with something more useful
      # in APERTA-8656
      value
    end
  end
end
