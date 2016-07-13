# AdhocAttachment represents a file attachment that is added to an
# adhoc task card that does not fall into the other predefined attachment
# categories such as Figure(s), SupportingInformationFile(s), etc.
class AdhocAttachment < Attachment
  IMAGE_TYPES = %w{jpg jpeg tiff tif gif png eps tif}

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
end
