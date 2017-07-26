class CustomCardTaskSerializer < TaskSerializer
  has_one :card_version, embed: :id, include: true
  has_many :apex_deliveries, embed: :id, include: true
end
