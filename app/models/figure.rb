class Figure < ActiveRecord::Base
  belongs_to :paper

  mount_uploader :attachment, AttachmentUploader
end
