class Attachment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :task
  has_one :paper, through: :task

  mount_uploader :file, AdhocAttachmentUploader

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  def image?
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
  end
end
