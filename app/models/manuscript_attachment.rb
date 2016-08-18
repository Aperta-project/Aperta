# Represents the uploaded manuscript source file
# e.g. "MyManuscript.docx"
class ManuscriptAttachment < Attachment
  has_paper_trail

  mount_uploader :file, AttachmentUploader
end
