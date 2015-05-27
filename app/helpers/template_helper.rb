module TemplateHelper
  def app_name
    ENV["APP_NAME"] || 'Tahi'
  end
end
