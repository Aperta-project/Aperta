# Represents the uploaded manuscript source file
# e.g. "MyManuscript.docx"
class ManuscriptAttachment < Attachment
  has_paper_trail

  # Never ever delete manuscripts, always keep them. Safe. Sound.
  def keep_file_when_replaced?
    true
  end
end
