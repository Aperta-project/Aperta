# Users can attach files to external correspondences. Behind the
# scenes they're saved and processed like any other attachment.
class CorrespondenceAttachment < Attachment
  self.public_resource = true
  self.notifications_enabled = false
  self.snapshottable = false
end
