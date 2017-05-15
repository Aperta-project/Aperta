# AdhocAttachment represents a file attachment that is added to a
# task card that does not fall into the other predefined attachment
# categories such as Figure(s), SupportingInformationFile(s), etc.
# "Adhoc" in this case does not imply the attachments are associated
# with an ad-hoc card.
class AdhocAttachment < Attachment
  self.public_resource = true
end
