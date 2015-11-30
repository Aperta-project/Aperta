class SourceUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/versioned_text/#{model.id}"
  end
end
