# Represents the source file for an uploaded manuscript, where the manuscript
# is a pdf file.
class SourcefileAttachment < Attachment
  has_paper_trail

  self.public_resource = false

  def keep_file_when_replaced?
    true
  end

  def download!(url, uploaded_by: nil)
    super
    self.paper.latest_version.update!(sourcefile_s3_path: self.s3_dir, sourcefile_filename: self[:file])
    paper.update!(state_updated_at: Time.current.utc)
  end
end
