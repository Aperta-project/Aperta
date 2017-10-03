class CustomCardTaskSerializer < TaskSerializer
  has_many :export_deliveries, embed: :id, include: true

  def include_card_version?
    true
  end
end
