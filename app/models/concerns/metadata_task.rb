module MetadataTask
  extend ActiveSupport::Concern
  include SubmissionTask

  included do
    Task.metadata_types ||= Set.new
    Task.metadata_types.add name

    self.snapshottable = true
  end
end
