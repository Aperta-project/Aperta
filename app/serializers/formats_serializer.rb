class FormatsSerializer < ActiveModel::Serializer
  attr_accessor :export_formats, :import_formats
  def attributes
    if Tahi::Application.config.ihat_supported_formats
      {
        export_formats: export_formats,
        import_formats: import_formats
      }
    else
      nil
    end
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
    formats_hash.map { |entry| { format: entry['format'] } }
  end
end
