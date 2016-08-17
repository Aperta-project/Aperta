class AffiliationSerializer < ActiveModel::Serializer
  has_one :user, include: true, embed: :id
  attributes :id,
    :name,
    :start_date,
    :end_date,
    :email,
    :department,
    :title,
    :country
end
