class CustomCardTaskSerializer < TaskSerializer
  has_many :apex_deliveries, embed: :id, include: true
end
