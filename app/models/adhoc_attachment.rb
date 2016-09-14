# AdhocAttachment represents a file attachment that is added to an
# adhoc task card that does not fall into the other predefined attachment
# categories such as Figure(s), SupportingInformationFile(s), etc.
class AdhocAttachment < Attachment
  self.public_resource = true
end
