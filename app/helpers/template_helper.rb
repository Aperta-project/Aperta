module TemplateHelper
  def app_name
    ENV["APP_NAME"] || 'DORK'
  end
end
