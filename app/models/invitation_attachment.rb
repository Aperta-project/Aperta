# Users can attach files to invitations. Behind the scenes they're
# saved and processed like any other attachment.
class InvitationAttachment < Attachment
  # Invitation attachments are get publicly accessible URLs
  self.public_resource = true
end
