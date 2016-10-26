class OrcidAccountSerializer < ActiveModel::Serializer
  attributes :id,
    :identifier,
    :name,
    :profile_url,
    :status,
    :oauth_authorize_url

  def id
    # Returning nil for the ID is an effective way to disable the feature on the
    # frontend. The connect to orcid button will remain disabled without an
    # OrcidAccount.
    return nil unless TahiEnv.orcid_connect_enabled?
    object.id
  end
end
