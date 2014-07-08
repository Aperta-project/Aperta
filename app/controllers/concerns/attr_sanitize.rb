module AttrSanitize
  extend ActiveSupport::Concern
  include ActionView::Helpers::SanitizeHelper

  def strip_tags!(model_params, key)
    return unless model_params[key]
    model_params[key] = strip_tags(CGI.unescapeHTML(model_params[key]))
  end
end
