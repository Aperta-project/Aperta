class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  mount_uploader :file, AdhocAttachmentUploader

  IMAGE_TYPES = %w{.jpg jpeg tiff tif gif png eps docx odt epub pdf tif}

  def image?
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
  end
end
