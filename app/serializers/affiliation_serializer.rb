class AffiliationSerializer < AuthzSerializer
  has_one :user, embed: :id
  attributes :id,
    :name,
    :start_date,
    :end_date,
    :email,
    :department,
    :title,
    :country
end
