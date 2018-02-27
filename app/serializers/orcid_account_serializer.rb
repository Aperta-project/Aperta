class OrcidAccountSerializer < AuthzSerializer
  attributes :id,
    :identifier,
    :name,
    :profile_url,
    :status,
    :oauth_authorize_url,
    :orcid_connect_enabled

  private

  def include_name?
    is_current_user?
  end

  def include_oauth_authorize_url?
    is_current_user?
  end

  def include_status?
    is_current_user?
  end

  def is_current_user?
    current_user.id == object.user_id
  end

  def orcid_connect_enabled
    TahiEnv.orcid_connect_enabled?
  end

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
