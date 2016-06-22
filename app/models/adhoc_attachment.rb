class AdhocAttachment < Attachment
  mount_uploader :file, AdhocAttachmentUploader

  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

  # Where the attachment is placed on S3 is partially determined by the symbol
  # that is given to `mount_uploader`. ProxyableResource (and it's URL helper)
  # assumes the AttachmentUploader will be mounted as `attachment`. To prevent a
  # production S3 data migration we're aliasing `attachment` to `file`.
  def attachment
    file
  end

  def filename
    self[:file]
  end

  def src
    non_expiring_proxy_url if done?
  end

  def detail_src(**opts)
    non_expiring_proxy_url(version: :detail, **opts) if done? && image?
  end

  def preview_src
    non_expiring_proxy_url(version: :preview) if done? && image?
  end

  def image?
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
  end

  private

  def done?
    status == 'done'
  end
end
