module MetadataTask
  extend ActiveSupport::Concern

  def authorize_update?(params, user)
    if user.site_admin?
      true
    else
      !paper.submitted?
    end
  end

  included do
    Task.metadata_types ||= []
    unless Task.metadata_types.include?(name)
      Task.metadata_types << name
    end
  end
end
