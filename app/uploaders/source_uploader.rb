class SourceUploader < CarrierWave::Uploader::Base

  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # uploads/paper/1/manuscript/source.docx
  def store_dir
    "uploads/paper/#{model.paper.id}/#{model.class.to_s.underscore}"
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "source.docx" if original_filename
  end
end
