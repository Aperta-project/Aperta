# Module to use for things that have a major and minor version.
module Versioned
  extend ActiveSupport::Concern
  included do
    scope :version_desc, -> { order('major_version DESC, minor_version DESC') }
    scope :version_asc, -> { order('major_version ASC, minor_version ASC') }
    scope :completed, -> { where.not(major_version: nil) }
    scope :drafts, -> { where(major_version: nil) }
  end
end
