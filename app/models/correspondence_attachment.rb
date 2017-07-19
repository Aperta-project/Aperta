# Users can attach files to external correspondences. Behind the
# scenes they're saved and processed like any other attachment.
class CorrespondenceAttachment < Attachment
  # Correspondence attachments are get publicly accessible URLs
  self.public_resource = true
end
