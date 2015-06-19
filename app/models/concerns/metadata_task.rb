module MetadataTask
  extend ActiveSupport::Concern
  include SubmissionTask

  def authorize_update?(params, user)
    if user.site_admin?
      true
    else
      # Is this actually related to editable?
      # Can we post when not editable? Must we be able to post while editable?
      paper.ongoing? || paper.in_revision? || paper.in_minor_revision?
    end
  end

  included do
    Task.metadata_types ||= Set.new
    Task.metadata_types.add name
  end
end
