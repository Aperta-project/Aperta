class SourceUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/versioned_text/#{model.id}"
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    'source.docx' if original_filename
  end
end
