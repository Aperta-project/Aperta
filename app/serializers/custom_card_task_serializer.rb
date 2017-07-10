class CustomCardTaskSerializer < TaskSerializer
  has_one :card_version, embed: :id, include: true
end
