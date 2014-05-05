module MetadataTask
  extend ActiveSupport::Concern
  def authorize_update!(params, user)
    if user.admin?
      true
    else
      !paper.submitted?
    end
  end
end
