module TemplateHelper
  def app_name
    ENV["APP_NAME"] || 'Aperta'
  end
end
