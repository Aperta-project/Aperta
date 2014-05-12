class Manuscript < ActiveRecord::Base
  belongs_to :paper

  mount_uploader :source, SourceUploader
end
