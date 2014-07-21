class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :id, include: true
end
