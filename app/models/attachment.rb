class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  mount_uploader :file, AdhocAttachmentUploader

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  def image?
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
  end

  after_destroy { |record| record.attachable.touch }

end
