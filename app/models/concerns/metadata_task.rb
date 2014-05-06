module MetadataTask
  extend ActiveSupport::Concern

  def authorize_update?(params, user)
    if user.admin?
      true
    else
      !paper.submitted?
    end
  end

  included do
    Task.register_metadata_type(self.name)
  end
end
