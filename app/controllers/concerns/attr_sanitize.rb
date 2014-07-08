module AttrSanitize
  extend ActiveSupport::Concern
  include ActionView::Helpers::SanitizeHelper

  def strip_tags!(model_params, key)
    attribute = model_params[key]
    if attribute
      model_params[key] = strip_tags(CGI.unescapeHTML(attribute))
    end
  end
end
