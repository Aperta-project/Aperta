class QuestionAttachmentUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage Rails.application.config.carrierwave_storage

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/question/#{model.owner_id}/" \
      "#{model.class.to_s.underscore}/#{model.id}"
  end
end
