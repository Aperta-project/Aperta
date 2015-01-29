class FormatsSerializer < ActiveModel::Serializer
  def attributes
    {
      import_formats: Tahi::Application.config.ihat_supported_import_formats,
      export_formats: Tahi::Application.config.ihat_supported_export_formats
    }
  end
end
