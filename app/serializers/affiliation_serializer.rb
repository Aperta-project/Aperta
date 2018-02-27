class AffiliationSerializer < AuthzSerializer
  has_one :user, include: true, embed: :id
  attributes :id,
    :name,
    :start_date,
    :end_date,
    :email,
    :department,
    :title,
    :country

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
