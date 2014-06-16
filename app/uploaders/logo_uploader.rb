class LogoUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path("/assets/no-journal-image.gif", digest: true)
  end
end
