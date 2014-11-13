class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  mount_uploader :file, AdhocAttachmentUploader

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps}

  def image?
    IMAGE_TYPES.include? file.file.extension
  end
end
