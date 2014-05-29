class EpubCoverUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg)
  end
end
