# Temporary uploader for supporting information file. This will be replaced once
# we start versioning attachment data on S3.
class SupportingInformationFileUploader < AttachmentUploader
  def store_dir
    model.try(:s3_dir) ||
      "uploads/attachments/#{model.id}/supporting_information_file/attachment/#{model.id}"
  end
end
