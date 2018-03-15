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

  def can_view?
    # This is only called from the top level, where we do not check permissions,
    # or from the author serializer. If it is called from the authors
    # serializer, check if the user can manage the paper or authors or is the
    # creator of the paper.
    return false if options[:paper].blank?
    scope.can?(:manage_paper_authors, options[:paper]) || scope == options[:paper].creator
  end
end
