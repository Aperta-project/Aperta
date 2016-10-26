class UserSerializer < ActiveModel::Serializer
  attributes :id,
    :avatar_url,
    :first_name,
    :full_name,
    :last_name,
    :username

  has_many :affiliations, embed: :id
  has_one :orcid_account, embed: :id
end
