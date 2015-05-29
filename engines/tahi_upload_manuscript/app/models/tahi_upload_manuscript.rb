module TahiUploadManuscript
  include MetadataTask

  def self.table_name_prefix
    'upload_manuscript_'
  end
end
