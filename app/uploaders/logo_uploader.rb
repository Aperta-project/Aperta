class LogoUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    "/assets/no-journal-image.gif"
  end
end
