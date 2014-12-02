class FormatsSerializer < ActiveModel::Serializer
  attr_accessor :export_formats, :import_formats
  def attributes
    {
      export_formats: export_formats,
      import_formats: import_formats
    }
  end

  private

  def formats
    JSON.parse Tahi::Application.config.ihat_supported_formats
  end

  def export_formats
    pluck_format formats['export_formats']
  end

  def import_formats
    pluck_format formats['import_formats']
  end

  def pluck_format(formats_hash)
    formats_hash.collect { |entry| { format: entry['format'] } }
  end
end
