class UserSerializer < AuthzSerializer
  attributes :id,
    :avatar_url,
    :first_name,
    :full_name,
    :last_name,
    :username

  has_many :affiliations, embed: :id
  has_one :orcid_account, embed: :id, include: true

  private

  def include_orcid_account?
    TahiEnv.orcid_connect_enabled?
  end

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
