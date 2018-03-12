class AdminEditSerializer < AuthzSerializer
  attributes :id,
    :notes,
    :active,
    :updated_at

  has_one :reviewer_report, include: false, embed: :id
  has_one :user, include: false, embed: :id
end
