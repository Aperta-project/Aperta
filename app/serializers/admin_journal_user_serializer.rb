class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name
end
