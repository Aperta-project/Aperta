module MetadataTask
  extend ActiveSupport::Concern
  include SubmissionTask

  def authorize_update?(params, user)
    if user.site_admin?
      true
    else
      paper.ongoing? || paper.in_revision?
    end
  end

  included do
    Task.metadata_types ||= Set.new
    Task.metadata_types.add name
  end
end
