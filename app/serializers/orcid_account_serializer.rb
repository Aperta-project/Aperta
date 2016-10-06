class OrcidAccountSerializer < ActiveModel::Serializer
  attributes :id,
    :identifier,
    :name,
    :profile_url,
    :status,
    :oauth_authorize_url
end
