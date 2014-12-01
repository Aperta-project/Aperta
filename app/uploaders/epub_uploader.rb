# This is for uploading EPub manuscripts to S3 during export to iHat
class EpubUploader < CarrierWave::Uploader::Base
  storage Rails.application.config.carrierwave_storage

  def store_dir
    "uploads/paper/#{model.id}/epub"
  end

  def filename
    "source.epub" if original_filename
  end
end
